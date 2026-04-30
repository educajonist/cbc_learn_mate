import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'subtopic_page.dart';

class SubcategoryPage extends StatelessWidget {
  final String categoryId;
  final String subjectId;

  const SubcategoryPage({
    super.key,
    required this.categoryId,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    final subcategoriesRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('subcategories');

    return Scaffold(
      appBar: AppBar(title: const Text('Subcategories')),
      body: StreamBuilder<QuerySnapshot>(
        stream: subcategoriesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No subcategories found'));
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
                        builder: (_) => SubtopicPage(
                          categoryId: categoryId,
                          subjectId: subjectId,
                          subcategoryId: doc.id,
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
