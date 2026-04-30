import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../widgets/video_player_widget.dart';

class NoteCanvasEditorPage extends StatefulWidget {
  final String categoryId;
  final String subjectId;
  final String sectionId;
  final String itemId;
  final String initialTitle;
  final String initialSubheading;

  const NoteCanvasEditorPage({
    super.key,
    required this.categoryId,
    required this.subjectId,
    required this.sectionId,
    required this.itemId,
    required this.initialTitle,
    this.initialSubheading = '',
  });

  @override
  State<NoteCanvasEditorPage> createState() => _NoteCanvasEditorPageState();
}

class _NoteCanvasEditorPageState extends State<NoteCanvasEditorPage> {
  late QuillController _quillController;
  late TextEditingController _titleController;
  late TextEditingController _subheadingController;
  final _editorFocusNode = FocusNode();
  final _editorScrollController = ScrollController();
  bool _loading = true;

  DocumentReference<Map<String, dynamic>> get _docRef => FirebaseFirestore
      .instance
      .collection('categories')
      .doc(widget.categoryId)
      .collection('subjects')
      .doc(widget.subjectId)
      .collection('sections')
      .doc(widget.sectionId)
      .collection('items')
      .doc(widget.itemId);

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _titleController = TextEditingController(text: widget.initialTitle);
    _subheadingController = TextEditingController(text: widget.initialSubheading);
    _load();
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    _subheadingController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final doc = await _docRef.get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final raw = data['data'];
        if (raw is String && raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            _setDocumentFromDelta(decoded);
          } else if (decoded is Map<String, dynamic>) {
            final delta = decoded['delta'];
            if (delta is List) {
              _setDocumentFromDelta(delta);
            } else if (decoded['blocks'] is List) {
              final legacyText = _extractLegacyTextFromBlocks(decoded['blocks'] as List);
              if (legacyText.trim().isNotEmpty) {
                _quillController.document = Document()..insert(0, legacyText);
              }
            }
          }
        }
      }
    } catch (_) {
      // keep silent for now; editor still opens with empty state
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _setDocumentFromDelta(List<dynamic> rawDelta) {
    try {
      final doc = Document.fromJson(rawDelta);
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      _quillController = QuillController.basic();
    }
  }

  String _extractLegacyTextFromBlocks(List<dynamic> blocks) {
    final buffer = StringBuffer();
    for (final entry in blocks) {
      if (entry is! Map) continue;
      final type = (entry['type'] ?? '').toString();
      final content = (entry['content'] ?? '').toString().trim();
      if (content.isEmpty) continue;
      if (type == 'image') {
        buffer.writeln('[Image] $content');
      } else if (type == 'video') {
        buffer.writeln('[Video] $content');
      } else {
        buffer.writeln(content);
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<void> _save() async {
    final payload = {
      'format': 'quill',
      'delta': _quillController.document.toDelta().toJson(),
      'plainText': _quillController.document.toPlainText(),
    };

    await _docRef.set({
      'type': 'note',
      'title': _titleController.text.trim().isEmpty
          ? 'Untitled Note'
          : _titleController.text.trim(),
      'subheading': _subheadingController.text.trim(),
      'data': jsonEncode(payload),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rich text saved')),
    );
  }

  Future<void> _insertEmbedUrl() async {
    final ctrl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Insert media URL'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'https://...',
            labelText: 'Image / video URL',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Insert'),
          ),
        ],
      ),
    );

    if (url == null || url.isEmpty) return;
    final index = _quillController.selection.baseOffset;
    _quillController.document.insert(index < 0 ? 0 : index, '$url\n');
  }

  int _wordCount() {
    final text = _quillController.document.toPlainText().trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;
  }

  int _characterCount() {
    final text = _quillController.document.toPlainText();
    return text.replaceAll('\n', '').length;
  }

  List<String> _extractMediaUrls() {
    final text = _quillController.document.toPlainText();
    final matches = RegExp(r'https?:\/\/[^\s]+')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();
    return matches;
  }

  Widget _buildMediaPreview() {
    final urls = _extractMediaUrls();
    if (urls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('No media links found in this note.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: urls.map((url) {
          final lower = url.toLowerCase();
          final isImage =
              lower.endsWith('.png') ||
              lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.webp') ||
              lower.endsWith('.gif');
          final isVideo =
              lower.contains('youtube.com') ||
              lower.contains('youtu.be') ||
              lower.endsWith('.mp4');

          if (isImage) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('Image failed'),
                    ),
                  ),
                ),
              ),
            );
          }
          if (isVideo) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: VideoPlayerWidget(url: url),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rich Text Editor'),
        actions: [
          IconButton(
            tooltip: 'Insert media URL',
            onPressed: _insertEmbedUrl,
            icon: const Icon(Icons.link),
          ),
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 56,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: QuillSimpleToolbar(controller: _quillController),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Heading',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _subheadingController,
                          decoration: const InputDecoration(
                            labelText: 'Subheading (optional)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.grey.shade50,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _insertEmbedUrl,
                        icon: const Icon(Icons.link),
                        label: const Text('Embed URL'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _quillController.document = Document();
                            _quillController.updateSelection(
                              const TextSelection.collapsed(offset: 0),
                              ChangeSource.local,
                            );
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Clear'),
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _quillController,
                        builder: (_, __) => Text(
                          '${_wordCount()} words  •  ${_characterCount()} chars',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _quillController,
                    builder: (_, __) {
                      final mediaCount = _extractMediaUrls().length;
                      return ColoredBox(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: QuillEditor(
                                          controller: _quillController,
                                          focusNode: _editorFocusNode,
                                          scrollController:
                                              _editorScrollController,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 4,
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              12,
                                              10,
                                              12,
                                              6,
                                            ),
                                            child: Text(
                                              'Inline Media ($mediaCount)',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Divider(height: 1),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: _buildMediaPreview(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}