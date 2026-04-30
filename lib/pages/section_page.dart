import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'content_page.dart';
import '../services/firestore_service.dart';

class SectionPage extends StatelessWidget {
  final String categoryId;
  final String subjectId;

  const SectionPage({
    super.key,
    required this.categoryId,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Sections")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.fetchSections(
          categoryId: categoryId,
          subjectId: subjectId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No sections found"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return Card(
                child: ListTile(
                  title: Text((doc.data())['title'] ?? doc.id),
                  subtitle: Text((doc.data())['type'] ?? 'General'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContentPage(
                          categoryId: categoryId,
                          subjectId: subjectId,
                          sectionId: doc.id,
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
