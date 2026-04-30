import 'package:cloud_firestore/cloud_firestore.dart';

class EnglishTopicsSeed {
  static Future<void> init(String subjectId) async {
    final firestore = FirebaseFirestore.instance;

    final subjectRef = firestore.collection('subjects').doc(subjectId);

    final topicsRef = subjectRef.collection('topics');

    final check = await topicsRef.get();
    if (check.docs.isNotEmpty) return;

    print("🔥 Creating English syllabus...");

    // =========================
    // SECTION A
    // =========================
    final sectionA = await topicsRef.add({
      "name": "Section A - Reading Skills",
    });

    // SUMMARY WRITING
    final summary = await sectionA.collection('topics').add({
      "name": "Item 1 - Summary Writing",
    });

    await summary.collection('levels').doc("S1").set({
      "content": "Identify main ideas",
    });
    await summary.collection('levels').doc("S2").set({
      "content": "Paraphrasing skills",
    });
    await summary.collection('levels').doc("S3").set({
      "content": "Concise summarization",
    });
    await summary.collection('levels').doc("S4").set({
      "content": "Exam-level summary writing",
    });

    // COMPREHENSION
    final comp = await sectionA.collection('topics').add({
      "name": "Item 2 - Comprehension",
    });

    await comp.collection('levels').doc("S1").set({
      "content": "Literal comprehension",
    });
    await comp.collection('levels').doc("S2").set({
      "content": "Understanding explicit meaning",
    });
    await comp.collection('levels').doc("S3").set({
      "content": "Inferential comprehension",
    });
    await comp.collection('levels').doc("S4").set({
      "content": "Advanced interpretation",
    });

    // =========================
    // SECTION B
    // =========================
    final sectionB = await topicsRef.add({
      "name": "Section B - Writing Skills",
    });

    // FUNCTIONAL WRITING
    final functional = await sectionB.collection('topics').add({
      "name": "Functional Writing",
    });

    await functional.collection('levels').doc("S1").set({
      "content": "Simple letters",
    });
    await functional.collection('levels').doc("S2").set({
      "content": "Formal letters",
    });
    await functional.collection('levels').doc("S3").set({
      "content": "Reports and speeches",
    });
    await functional.collection('levels').doc("S4").set({
      "content": "Exam writing formats",
    });

    // CREATIVE WRITING
    final creative = await sectionB.collection('topics').add({
      "name": "Creative Writing",
    });

    await creative.collection('levels').doc("S1").set({
      "content": "Simple narratives",
    });
    await creative.collection('levels').doc("S2").set({
      "content": "Descriptive essays",
    });
    await creative.collection('levels').doc("S3").set({
      "content": "Story development",
    });
    await creative.collection('levels').doc("S4").set({
      "content": "Advanced composition",
    });

    print("✅ English syllabus created");
  }
}
