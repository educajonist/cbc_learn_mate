import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class NotePage extends StatefulWidget {
  final String categoryId;
  final String subjectId;
  final String subcategoryId;
  final String subtopicId;

  const NotePage({
    super.key,
    required this.categoryId,
    required this.subjectId,
    required this.subcategoryId,
    required this.subtopicId,
  });

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Map<String, dynamic>> blocks = [];

  CollectionReference get notesRef => FirebaseFirestore.instance
      .collection('categories')
      .doc(widget.categoryId)
      .collection('subjects')
      .doc(widget.subjectId)
      .collection('subcategories')
      .doc(widget.subcategoryId)
      .collection('subtopics')
      .doc(widget.subtopicId)
      .collection('notes');

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final snapshot = await notesRef.orderBy('order').get();

    setState(() {
      blocks = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'type': data['type'],
          'content': data['content'] ?? '',
          'width': (data['width'] ?? 300).toDouble(),
          'height': (data['height'] ?? 150).toDouble(),
          'order': data['order'] ?? 0,
        };
      }).toList();
    });
  }

  Future<void> saveNotes() async {
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];

      await notesRef.doc(block['id']).set({
        'type': block['type'],
        'content': block['content'],
        'width': (block['width'] as double),
        'height': (block['height'] as double),
        'order': i,
      });
    }
  }

  String generateId() => Random().nextInt(99999999).toString();

  void addTextBlock() {
    setState(() {
      blocks.add({
        'id': generateId(),
        'type': 'text',
        'content': '',
        'width': 400.0,
        'height': 150.0,
      });
    });
  }

  void addImageBlock() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Image URL"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                blocks.add({
                  'id': generateId(),
                  'type': 'image',
                  'content': controller.text,
                  'width': 300.0,
                  'height': 200.0,
                });
              });
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void addVideoBlock() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("YouTube URL"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                blocks.add({
                  'id': generateId(),
                  'type': 'video',
                  'content': controller.text,
                  'width': 400.0,
                  'height': 250.0,
                });
              });
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  Widget buildBlock(Map<String, dynamic> block) {
    final id = block['id'];

    return Container(
      key: ValueKey(id),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                double width = (block['width'] as double);
                double height = (block['height'] as double);

                width = max<double>(150.0, width + details.delta.dx);
                height = max<double>(100.0, height + details.delta.dy);

                block['width'] = width;
                block['height'] = height;
              });
            },
            child: Container(
              width: (block['width'] as double),
              height: (block['height'] as double),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: buildContent(block),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    blocks.removeWhere((b) => b['id'] == id);
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildContent(Map<String, dynamic> block) {
    switch (block['type']) {
      case 'text':
        return TextField(
          controller: TextEditingController(text: block['content']),
          maxLines: null,
          decoration: const InputDecoration(
            hintText: "Write notes...",
            border: InputBorder.none,
          ),
          onChanged: (value) => block['content'] = value,
        );

      case 'image':
        return Image.network(
          block['content'],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Text("Invalid Image URL")),
        );

      case 'video':
        return const Center(
          child: Text("Video preview coming next upgrade"),
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveNotes,
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'text',
            onPressed: addTextBlock,
            child: const Icon(Icons.text_fields),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'image',
            onPressed: addImageBlock,
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'video',
            onPressed: addVideoBlock,
            child: const Icon(Icons.video_library),
          ),
        ],
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.all(16),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = blocks.removeAt(oldIndex);
            blocks.insert(newIndex, item);
          });
        },
        children: blocks.map(buildBlock).toList(),
      ),
    );
  }
}
