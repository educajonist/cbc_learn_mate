import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../services/firestore_service.dart';
import '../widgets/video_player_widget.dart';

class ContentPage extends StatelessWidget {
  final String categoryId;
  final String subjectId;
  final String sectionId;

  const ContentPage({
    super.key,
    required this.categoryId,
    required this.subjectId,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Content"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.fetchItems(
          categoryId: categoryId,
          subjectId: subjectId,
          sectionId: sectionId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading content"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No content available"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final type = (data['type'] ?? '').toString();
              final title = (data['title'] ?? '').toString();
              final subheading = (data['subheading'] ?? '').toString();
              final body = (data['data'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(title.isEmpty ? "(Untitled)" : title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (subheading.isNotEmpty)
                        Text(
                          subheading,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        _previewText(type, body),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openContent(
                    context,
                    type: type,
                    title: title,
                    data: body,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _previewText(String type, String body) {
    if (type == 'note' || type == 'note_canvas') {
      final parsed = _tryParseMap(body);
      if (parsed != null && parsed['format'] == 'quill') {
        final plain = (parsed['plainText'] ?? '').toString().trim();
        return plain.isEmpty ? "No note content" : plain;
      }
      final lines = body
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return lines.isEmpty ? "No note content" : lines.first;
    }
    return type;
  }

  void _openContent(
    BuildContext context, {
    required String type,
    required String title,
    required String data,
  }) {
    if (type == 'note' || type == 'note_canvas') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RichTextNoteReaderPage(
            title: title.isEmpty ? "Note" : title,
            rawData: data,
          ),
        ),
      );
      return;
    }

    if (type == 'video') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultimediaContentPage(
            type: "video",
            title: title.isEmpty ? "Video" : title,
            data: data,
          ),
        ),
      );
      return;
    }

    if (type == 'image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultimediaContentPage(
            type: "image",
            title: title.isEmpty ? "Image" : title,
            data: data,
          ),
        ),
      );
      return;
    }

    if (type == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultimediaContentPage(
            type: "pdf",
            title: title.isEmpty ? "PDF" : title,
            data: data,
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title.isEmpty ? "Content" : title),
        content: SelectableText(
          data.isEmpty ? "No data available." : data,
        ),
      ),
    );
  }

  Map<String, dynamic>? _tryParseMap(String value) {
    try {
      final obj = jsonDecode(value);
      if (obj is Map<String, dynamic>) return obj;
      return null;
    } catch (_) {
      return null;
    }
  }
}

class MultimediaContentPage extends StatelessWidget {
  final String type;
  final String title;
  final String data;

  const MultimediaContentPage({
    super.key,
    required this.type,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildMedia(),
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (data.trim().isEmpty) {
      return const Center(child: Text("No media URL available."));
    }

    if (type == "video") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Center(child: VideoPlayerWidget(url: data))),
          const SizedBox(height: 12),
          SelectableText("Source URL:\n$data"),
        ],
      );
    }

    if (type == "image") {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Center(
          child: Image.network(
            data,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Text("Could not load image."),
          ),
        ),
      );
    }

    if (type == "pdf") {
      return SelectableText(
        "PDF embedding is not configured yet.\n\nPDF URL:\n$data",
        style: const TextStyle(fontSize: 16, height: 1.5),
      );
    }

    return SelectableText(data);
  }
}

class RichTextNoteReaderPage extends StatelessWidget {
  final String title;
  final String rawData;

  const RichTextNoteReaderPage({
    super.key,
    required this.title,
    required this.rawData,
  });

  Document _documentFromRaw() {
    try {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic> &&
          decoded['format'] == 'quill' &&
          decoded['delta'] is List) {
        return Document.fromJson(decoded['delta'] as List);
      }
      if (decoded is List) {
        return Document.fromJson(decoded);
      }
    } catch (_) {
      // fall back to plain text below
    }
    return Document()..insert(0, rawData);
  }

  List<String> _extractMediaUrls(Document document) {
    final text = document.toPlainText();
    return RegExp(r'https?:\/\/[^\s]+')
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();
  }

  Widget _buildInlineMedia(List<String> urls) {
    if (urls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("No embedded media links in this note."),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
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
                height: 190,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text("Image failed to load")),
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
                height: 210,
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
    final document = _documentFromRaw();
    final mediaUrls = _extractMediaUrls(document);
    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    final focusNode = FocusNode();
    final scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 7,
                        child: QuillEditor(
                          controller: controller,
                          focusNode: focusNode,
                          scrollController: scrollController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                                child: Text(
                                  'Embedded Media (${mediaUrls.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: _buildInlineMedia(mediaUrls),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}