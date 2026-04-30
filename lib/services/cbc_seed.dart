import 'package:cloud_firestore/cloud_firestore.dart';

class CBCSeed {
  static Future<void> seedAll() async {
    final firestore = FirebaseFirestore.instance;

    print("🔥 Seeding CBC data...");

    // 🚨 DELETE OLD DATA (FULL RESET)
    final categoriesSnapshot = await firestore.collection('categories').get();

    for (var doc in categoriesSnapshot.docs) {
      await doc.reference.delete();
    }

    // =========================
    // 📚 COMPULSORY
    // =========================
    final compulsoryRef = await firestore.collection('categories').add({
      "name": "Compulsory Subjects",
      "createdAt": FieldValue.serverTimestamp(),
    });

    final compulsorySubjects = [
      "English Language",
      "Mathematics",
      "Biology",
      "Chemistry",
      "Physics",
      "Geography",
      "History & Political Education",
    ];

    for (var subject in compulsorySubjects) {
      await compulsoryRef.collection('subjects').add({
        "name": subject,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    // =========================
    // 🎓 ELECTIVES
    // =========================
    final electivesRef = await firestore.collection('categories').add({
      "name": "Electives",
      "createdAt": FieldValue.serverTimestamp(),
    });

    final electivesData = {
      "Religious Education": [
        "CRE",
        "IRE",
      ],
      "Vocational / Technical": [
        "ICT",
        "Agriculture",
        "Nutrition & Food Technology",
        "Entrepreneurship",
      ],
      "Languages": [
        "Kiswahili",
        "French",
        "German",
        "Arabic",
        "Latin",
        "Chinese",
        "Luganda",
        "Leblango",
        "Leb Acoli",
        "Runyankore-Rukiga",
        "Runyoro-Rutooro",
        "Lusoga",
        "Lumasaaba",
        "Ateso",
        "Dhopadhola",
        "Lugbarati",
      ],
      "Creative Arts": [
        "Art & Design",
        "Performing Arts (Music)",
        "Physical Education",
      ],
    };

    for (var subcategory in electivesData.keys) {
      final subRef = await electivesRef.collection('subcategories').add({
        "name": subcategory,
        "createdAt": FieldValue.serverTimestamp(),
      });

      for (var subject in electivesData[subcategory]!) {
        await subRef.collection('subjects').add({
          "name": subject,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    }

    print("✅ CBC DATA SEEDED SUCCESSFULLY!");
  }
}
