import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  static Future<void> seedEnglish(String selectedClass) async {
    final firestore = FirebaseFirestore.instance;

    final topics = [
      // Reading
      "Summary Writing",
      "Inferential Comprehension",

      // Writing
      "Functional Writing",
      "Creative Writing",
    ];

    for (var title in topics) {
      final existing = await firestore
          .collection('topics')
          .where('title', isEqualTo: title)
          .where('subject', isEqualTo: "English")
          .where('class', isEqualTo: selectedClass)
          .get();

      if (existing.docs.isEmpty) {
        await firestore.collection('topics').add({
          "title": title,
          "subject": "English",
          "class": selectedClass,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
