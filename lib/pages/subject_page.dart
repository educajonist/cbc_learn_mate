import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'section_page.dart';
import '../services/firestore_service.dart';

class SubjectPage extends StatelessWidget {
  final String categoryId;

  const SubjectPage({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Subjects")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.fetchSubjects(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No subjects found"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return Card(
                child: ListTile(
                  title: Text(doc['name'] ?? ''),
                  subtitle: Text(doc.id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SectionPage(
                          categoryId: categoryId,
                          subjectId: doc.id,
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
