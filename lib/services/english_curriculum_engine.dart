import 'package:cloud_firestore/cloud_firestore.dart';

class EnglishCurriculumEngine {
  static Future<void> seedEnglishCurriculum() async {
    final subjectsRef = FirebaseFirestore.instance.collection('subjects');

    final englishDoc =
        await subjectsRef.where("name", isEqualTo: "English Language").get();

    if (englishDoc.docs.isEmpty) return;

    final englishId = englishDoc.docs.first.id;

    final sectionsRef = subjectsRef.doc(englishId).collection('sections');

    // =========================
    // SECTION A - READING SKILLS
    // =========================
    final reading = await sectionsRef
        .doc('reading_skills')
        .set({"name": "Section A - Reading Skills"});

    // SUMMARY WRITING
    final summaryRef =
        sectionsRef.doc('reading_skills').collection('summary_writing');

    await summaryRef.doc('S1').set({
      "class": "S1",
      "focus": "Identifying main ideas",
      "topics": ["Personal life", "Food", "Travel"],
    });

    await summaryRef.doc('S2').set({
      "class": "S2",
      "focus": "Structured note making",
      "topics": ["Modern communication", "Celebrations", "Tourism"],
    });

    await summaryRef.doc('S3').set({
      "class": "S3",
      "focus": "Summarising factual prose",
      "topics": ["Integrity", "Relationships", "Education"],
    });

    await summaryRef.doc('S4').set({
      "class": "S4",
      "focus": "Analytical summarising",
      "topics": ["Media", "Culture", "Globalisation"],
    });

    // COMPREHENSION
    final compRef =
        sectionsRef.doc('reading_skills').collection('comprehension');

    await compRef.doc('literal').set({
      "type": "Literal Comprehension",
      "progression": "S1–S2 focus",
      "skills": [
        "Locate specific information",
        "Answer direct questions",
        "Extract facts"
      ],
      "topics": ["Personal", "Market", "Technology", "Travel"],
    });

    await compRef.doc('inferential').set({
      "type": "Inferential Comprehension",
      "progression": "S3–S4 focus",
      "skills": [
        "Interpret implied meaning",
        "Read between lines",
        "Evaluate viewpoints"
      ],
      "topics": [
        "Identity",
        "Relationships",
        "Integrity",
        "Media",
        "Globalisation"
      ],
    });

    // =========================
    // SECTION B - WRITING SKILLS
    // =========================
    final writing = sectionsRef.doc('writing_skills');

    await writing.set({"name": "Section B - Writing Skills"});

    // FUNCTIONAL WRITING
    final functionalRef = writing.collection('functional_writing');

    await functionalRef.doc('S1').set({
      "class": "S1",
      "types": ["Letters", "Messages", "Forms", "Complaints"],
      "topics": ["Family", "Market", "School"],
    });

    await functionalRef.doc('S2').set({
      "class": "S2",
      "types": ["Applications", "Apologies", "Journals"],
      "topics": ["Technology", "Tourism"],
    });

    await functionalRef.doc('S3').set({
      "class": "S3",
      "types": ["Formal letters", "Reports", "Inquiries"],
      "topics": ["Integrity", "Education"],
    });

    await functionalRef.doc('S4').set({
      "class": "S4",
      "types": ["Reports", "CVs", "Job Applications", "Notices"],
      "topics": ["Career", "Employment"],
    });

    // CREATIVE WRITING
    final creativeRef = writing.collection('creative_writing');

    await creativeRef.doc('S1').set({
      "class": "S1",
      "types": ["Narratives", "Descriptions"],
      "topics": ["Personal life", "Food"],
    });

    await creativeRef.doc('S2').set({
      "class": "S2",
      "types": ["Paragraphs", "Short essays"],
      "topics": ["Celebrations", "Leisure"],
    });

    await creativeRef.doc('S3').set({
      "class": "S3",
      "types": ["Essays", "Personal viewpoints"],
      "topics": ["Identity", "Relationships"],
    });

    await creativeRef.doc('S4').set({
      "class": "S4",
      "types": ["Extended essays", "Arguments"],
      "topics": ["Culture", "Globalisation"],
    });
  }
}
