import 'package:cloud_firestore/cloud_firestore.dart';

class CbcSeeder {
  static Future<void> seedSubjectsIfEmpty() async {
    final ref = FirebaseFirestore.instance.collection('subjects');

    final snapshot = await ref.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      // Already seeded → prevent duplicates
      return;
    }

    final subjects = [
      "English Language",
      "Mathematics",
      "Biology",
      "Chemistry",
      "Physics",
      "Geography",
      "History & Political Education",
    ];

    for (final name in subjects) {
      await ref.add({
        "name": name,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }
}
