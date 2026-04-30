import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateNotePage extends StatefulWidget {
  final String topicId;

  const CreateNotePage({super.key, required this.topicId});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final titleController = TextEditingController();
  final quillController = QuillController.basic();

  final focusNode = FocusNode();
  final scrollController = ScrollController();

  final ImagePicker picker = ImagePicker();

  String? videoUrl;
  bool isLoading = false;

  // 🖼️ IMAGE
  Future<void> insertImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final index = quillController.selection.baseOffset;

    quillController.document.insert(
      index,
      BlockEmbed.image(image.path),
    );
  }

  // 🎥 VIDEO UPLOAD
  Future<void> uploadVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null) return;

    final file = result.files.first;

    final ref = FirebaseStorage.instance.ref().child('videos/${file.name}');

    await ref.putData(file.bytes!);

    final url = await ref.getDownloadURL();

    setState(() {
      videoUrl = url;
    });
  }

  // 💾 SAVE
  Future<void> saveNote() async {
    if (titleController.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    final contentJson = quillController.document.toDelta().toJson();

    await FirebaseFirestore.instance.collection('notes').add({
      "title": titleController.text.trim(),
      "content": contentJson,
      "topicId": widget.topicId,
      "videoUrl": videoUrl,
      "createdAt": FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: insertImage,
          ),
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: uploadVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: QuillSimpleToolbar(controller: quillController),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: QuillEditor(
                controller: quillController,
                focusNode: focusNode,
                scrollController: scrollController,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : saveNote,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("Save Note"),
          ),
        ],
      ),
    );
  }
}
