import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/role_service.dart';
import 'subtopic_page.dart';

class TopicPage extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const TopicPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  bool canManageContent = false;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initRole();
  }

  Future<void> initRole() async {
    canManageContent = await RoleService.canManageContent();
    setState(() {});
  }

  // =========================
  // ADD TOPIC
  // =========================
  Future<void> addTopic() async {
    final name = controller.text.trim();
    if (name.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('subjects')
        .doc(widget.subjectId)
        .collection('topics')
        .add({
      "name": name,
      "createdAt": FieldValue.serverTimestamp(),
    });

    controller.clear();
  }

  // =========================
  // DELETE TOPIC
  // =========================
  Future<void> deleteTopic(String id) async {
    await FirebaseFirestore.instance
        .collection('subjects')
        .doc(widget.subjectId)
        .collection('topics')
        .doc(id)
        .delete();
  }

  // =========================
  // EDIT TOPIC
  // =========================
  Future<void> editTopic(String id, String oldName) async {
    controller.text = oldName;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Topic"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Topic name"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('subjects')
                  .doc(widget.subjectId)
                  .collection('topics')
                  .doc(id)
                  .update({"name": newName});

              controller.clear();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        actions: [
          if (canManageContent)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Add Topic"),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: "Topic name"),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          await addTopic();
                          Navigator.pop(context);
                        },
                        child: const Text("Add"),
                      )
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subjects')
            .doc(widget.subjectId)
            .collection('topics')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No topics found"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final name = doc['name'] ?? "No Name";

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  // =========================
                  // OPEN SUBTOPICS
                  // =========================
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubtopicPage(
                          subjectId: widget.subjectId,
                          topicId: doc.id,
                          topicName: name,
                        ),
                      ),
                    );
                  },

                  // =========================
                  // OWNER CONTROLS
                  // =========================
                  trailing: canManageContent
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editTopic(doc.id, name),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteTopic(doc.id),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
