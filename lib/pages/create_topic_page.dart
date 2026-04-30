import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTopicPage extends StatefulWidget {
  final String subjectName;
  final String selectedClass;

  const CreateTopicPage({
    super.key,
    required this.subjectName,
    required this.selectedClass,
  });

  @override
  State<CreateTopicPage> createState() => _CreateTopicPageState();
}

class _CreateTopicPageState extends State<CreateTopicPage> {
  final titleController = TextEditingController();
  bool isLoading = false;

  Future<void> createTopic() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter topic title")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('topics').add({
        "title": titleController.text.trim(),
        "subject": widget.subjectName,
        "class": widget.selectedClass,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Topic"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Topic Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : createTopic,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create Topic"),
            ),
          ],
        ),
      ),
    );
  }
}
