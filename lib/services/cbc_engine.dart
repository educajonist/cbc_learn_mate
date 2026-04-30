import 'package:cloud_firestore/cloud_firestore.dart';

class CBCEngine {
  static Future<void> generateEnglish(String subjectId) async {
    final base =
        FirebaseFirestore.instance.collection('subjects').doc(subjectId);

    // SECTION A
    final sectionA = await base.collection('topics').add({
      "name": "Section A - Reading Skills",
    });

    // Summary Writing
    await sectionA.collection('subtopics').add({
      "name": "Summary Writing (S1–S4)",
      "content": [
        "S1–S2: Identifying main ideas",
        "S3: Writing summaries",
        "S4: Analytical summarising"
      ]
    });

    // Literal Comprehension
    await sectionA.collection('subtopics').add({
      "name": "Literal Comprehension",
      "content": [
        "S1: Locate information",
        "S2: Extract meaning",
        "S3: Gather facts",
        "S4: Multi-source reading"
      ]
    });

    // Inferential
    await sectionA.collection('subtopics').add({
      "name": "Inferential Comprehension",
      "content": [
        "S1: Basic interpretation",
        "S2: Begin inference",
        "S3: Infer meaning",
        "S4: Critical analysis"
      ]
    });

    // SECTION B
    final sectionB = await base.collection('topics').add({
      "name": "Section B - Writing Skills",
    });

    await sectionB.collection('subtopics').add({
      "name": "Functional Writing",
      "content": [
        "S1: Letters, forms",
        "S2: Applications",
        "S3: Reports",
        "S4: CVs & formal writing"
      ]
    });

    await sectionB.collection('subtopics').add({
      "name": "Creative Writing",
      "content": [
        "S1: Simple narratives",
        "S2: Paragraphs",
        "S3: Essays",
        "S4: Advanced composition"
      ]
    });
  }
}
