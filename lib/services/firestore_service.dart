import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= CATEGORIES =================
  Future<void> createCategory({
    String? id,
    required String name,
    String description = '',
  }) async {
    final categoriesRef = _db.collection('categories');
    final categoryRef = (id != null && id.trim().isNotEmpty)
        ? categoriesRef.doc(id.trim())
        : categoriesRef.doc();

    await categoryRef.set({
      'name': name.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchCategories() {
    return _db.collection('categories').orderBy('name').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategories() {
    return fetchCategories();
  }

  Future<void> updateCategory({
    required String categoryId,
    required String name,
    String? description,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (description != null) {
      payload['description'] = description.trim();
    }

    await _db.collection('categories').doc(categoryId).update(payload);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }

  // ================= SUBJECTS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchSubjects(String categoryId) {
    return _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .orderBy('name')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSubjects(String categoryId) {
    return fetchSubjects(categoryId);
  }

  Future<void> createSubject({
    required String categoryId,
    String? subjectId,
    required String name,
    String icon = '',
  }) async {
    final subjectsRef =
        _db.collection('categories').doc(categoryId).collection('subjects');
    final subjectRef = (subjectId != null && subjectId.trim().isNotEmpty)
        ? subjectsRef.doc(subjectId.trim())
        : subjectsRef.doc();

    await subjectRef.set({
      'name': name.trim(),
      'icon': icon.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSubject({
    required String categoryId,
    required String subjectId,
    required String name,
    String? icon,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (icon != null) {
      payload['icon'] = icon.trim();
    }

    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .update(payload);
  }

  Future<void> deleteSubject({
    required String categoryId,
    required String subjectId,
  }) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .delete();
  }

  // ================= SECTIONS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchSections({
    required String categoryId,
    required String subjectId,
  }) {
    return _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('sections')
        .orderBy('title')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSections({
    required String categoryId,
    required String subjectId,
  }) {
    return fetchSections(categoryId: categoryId, subjectId: subjectId);
  }

  Future<void> createSection({
    required String categoryId,
    required String subjectId,
    String? sectionId,
    required String title,
    String type = 'General',
  }) async {
    final sectionsRef = _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('sections');

    final sectionRef = (sectionId != null && sectionId.trim().isNotEmpty)
        ? sectionsRef.doc(sectionId.trim())
        : sectionsRef.doc();

    await sectionRef.set({
      'title': title.trim(),
      'type': type.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSection({
    required String categoryId,
    required String subjectId,
    required String sectionId,
    required String title,
    String? type,
  }) async {
    final payload = <String, dynamic>{
      'title': title.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (type != null) {
      payload['type'] = type.trim();
    }

    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('sections')
        .doc(sectionId)
        .update(payload);
  }

  Future<void> deleteSection({
    required String categoryId,
    required String subjectId,
    required String sectionId,
  }) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('sections')
        .doc(sectionId)
        .delete();
  }

  // ================= ITEMS / CONTENT =================
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchItems({
    required String categoryId,
    required String subjectId,
    required String sectionId,
  }) {
    return _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('sections')
        .doc(sectionId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addContent({
    required String categoryId,
    required String subjectId,
    required String sectionId,
    required String type,
    required String title,
    required String data,
    String? subheading,
  }) async {
    final payload = <String, dynamic>{
      'type': type,
      'title': title.trim(),
      'data': data.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (subheading != null) {
      payload['subheading'] = subheading.trim();
    }

    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('sections')
        .doc(sectionId)
        .collection('items')
        .add(payload);
  }

  Future<void> updateItem({
    required String categoryId,
    required String subjectId,
    required String sectionId,
    required String itemId,
    required String title,
    required String type,
    required String data,
    String? subheading,
  }) async {
    final payload = <String, dynamic>{
      'title': title.trim(),
      'type': type.trim(),
      'data': data.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (subheading != null) {
      payload['subheading'] = subheading.trim();
    }

    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('sections')
        .doc(sectionId)
        .collection('items')
        .doc(itemId)
        .update(payload);
  }

  Future<void> deleteItem({
    required String categoryId,
    required String subjectId,
    required String sectionId,
    required String itemId,
  }) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subjects')
        .doc(subjectId)
        .collection('sections')
        .doc(sectionId)
        .collection('items')
        .doc(itemId)
        .delete();
  }
}