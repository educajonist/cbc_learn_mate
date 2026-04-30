import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_page.dart';

class SubtopicPage extends StatelessWidget {
  final String categoryId;
  final String subjectId;
  final String subcategoryId;

  const SubtopicPage({
    super.key,
    required this.categoryId,
    required this.subjectId,
    required this.subcategoryId,
  });

  @override
  Widget build(BuildContext context) {
    final subtopicsRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('subcategories')
        .doc(subcategoryId)
        .collection('subtopics');

    return Scaffold(
      appBar: AppBar(title: const Text('Subtopics')),
      body: StreamBuilder<QuerySnapshot>(
        stream: subtopicsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No subtopics found'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(doc['name'] ?? 'No Name'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotePage(
                          categoryId: categoryId,
                          subjectId: subjectId,
                          subcategoryId: subcategoryId,
                          subtopicId: doc.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
