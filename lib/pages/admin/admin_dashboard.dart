import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'note_canvas_editor_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final service = FirestoreService();

  String? selectedCategoryId;
  String? selectedSubjectId;
  String? selectedSectionId;

  final categoryCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  final sectionCtrl = TextEditingController();
  final sectionTypeCtrl = TextEditingController(text: 'General');

  final contentTitleCtrl = TextEditingController();
  final contentSubheadingCtrl = TextEditingController();
  final contentDataCtrl = TextEditingController();

  String contentType = "note";

  @override
  void dispose() {
    categoryCtrl.dispose();
    subjectCtrl.dispose();
    sectionCtrl.dispose();
    sectionTypeCtrl.dispose();
    contentTitleCtrl.dispose();
    contentSubheadingCtrl.dispose();
    contentDataCtrl.dispose();
    super.dispose();
  }

  Future<void> _editCategory(String id, String currentName) async {
    final ctrl = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Category"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Category name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              await service.updateCategory(categoryId: id, name: v);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _editSubject(String id, String currentName) async {
    if (selectedCategoryId == null) return;
    final ctrl = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Subject"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Subject name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              await service.updateSubject(
                categoryId: selectedCategoryId!,
                subjectId: id,
                name: v,
              );
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _editSection(
    String id,
    String currentTitle,
    String currentType,
  ) async {
    if (selectedCategoryId == null || selectedSubjectId == null) return;

    final titleCtrl = TextEditingController(text: currentTitle);
    final typeCtrl = TextEditingController(text: currentType);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Section"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(labelText: "Type"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final t = titleCtrl.text.trim();
              final ty = typeCtrl.text.trim();
              if (t.isEmpty) return;

              await service.updateSection(
                categoryId: selectedCategoryId!,
                subjectId: selectedSubjectId!,
                sectionId: id,
                title: t,
                type: ty.isEmpty ? "General" : ty,
              );
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _openRichTextEditor({
    String? itemId,
    String? title,
    String? subheading,
  }) {
    if (selectedCategoryId == null ||
        selectedSubjectId == null ||
        selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select category, subject, and section first"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteCanvasEditorPage(
          categoryId: selectedCategoryId!,
          subjectId: selectedSubjectId!,
          sectionId: selectedSectionId!,
          itemId: itemId ??
              FirebaseFirestore.instance
                  .collection('tmp')
                  .doc()
                  .id,
          initialTitle: title ?? 'Untitled Note',
          initialSubheading: subheading ?? '',
        ),
      ),
    );
  }

  Future<void> _promptAndCreateRichTextNote() async {
    if (selectedCategoryId == null ||
        selectedSubjectId == null ||
        selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select category, subject, and section first"),
        ),
      );
      return;
    }

    final headingCtrl = TextEditingController();
    final subheadingCtrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Rich Text Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: headingCtrl,
              decoration: const InputDecoration(labelText: 'Heading'),
            ),
            TextField(
              controller: subheadingCtrl,
              decoration: const InputDecoration(
                labelText: 'Subheading (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (headingCtrl.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created != true) return;
    if (!mounted) return;
    _openRichTextEditor(
      title: headingCtrl.text.trim(),
      subheading: subheadingCtrl.text.trim(),
    );
  }

  Widget _actions({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Wrap(
      spacing: 8,
      children: [
        OutlinedButton(onPressed: onEdit, child: const Text("Edit")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: onDelete,
          child: const Text("Delete"),
        ),
      ],
    );
  }

  Widget _categoryList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: service.fetchCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text("No categories yet");

        return Column(
          children: docs.map((doc) {
            final name = (doc.data()['name'] ?? '').toString();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(name),
                      selected: selectedCategoryId == doc.id,
                      onTap: () {
                        setState(() {
                          selectedCategoryId = doc.id;
                          selectedSubjectId = null;
                          selectedSectionId = null;
                        });
                      },
                    ),
                    _actions(
                      onEdit: () => _editCategory(doc.id, name),
                      onDelete: () async => service.deleteCategory(doc.id),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _subjectList() {
    if (selectedCategoryId == null) return const Text("Select category first");

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: service.fetchSubjects(selectedCategoryId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text("No subjects yet");

        return Column(
          children: docs.map((doc) {
            final name = (doc.data()['name'] ?? '').toString();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(name),
                      selected: selectedSubjectId == doc.id,
                      onTap: () {
                        setState(() {
                          selectedSubjectId = doc.id;
                          selectedSectionId = null;
                        });
                      },
                    ),
                    _actions(
                      onEdit: () => _editSubject(doc.id, name),
                      onDelete: () async {
                        await service.deleteSubject(
                          categoryId: selectedCategoryId!,
                          subjectId: doc.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _sectionList() {
    if (selectedSubjectId == null) return const Text("Select subject first");

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: service.fetchSections(
        categoryId: selectedCategoryId!,
        subjectId: selectedSubjectId!,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text("No sections yet");

        return Column(
          children: docs.map((doc) {
            final title = (doc.data()['title'] ?? '').toString();
            final type = (doc.data()['type'] ?? 'General').toString();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(title),
                      subtitle: Text(type),
                      selected: selectedSectionId == doc.id,
                      onTap: () {
                        setState(() {
                          selectedSectionId = doc.id;
                        });
                      },
                    ),
                    _actions(
                      onEdit: () => _editSection(doc.id, title, type),
                      onDelete: () async {
                        await service.deleteSection(
                          categoryId: selectedCategoryId!,
                          subjectId: selectedSubjectId!,
                          sectionId: doc.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _createCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Create Category"),
        TextField(controller: categoryCtrl),
        ElevatedButton(
          onPressed: () async {
            final value = categoryCtrl.text.trim();
            if (value.isEmpty) return;
            await service.createCategory(id: value, name: value);
            categoryCtrl.clear();
          },
          child: const Text("Create"),
        ),
      ],
    );
  }

  Widget _createSubject() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Create Subject"),
        TextField(controller: subjectCtrl),
        ElevatedButton(
          onPressed: () async {
            if (selectedCategoryId == null) return;
            final value = subjectCtrl.text.trim();
            if (value.isEmpty) return;
            await service.createSubject(
              categoryId: selectedCategoryId!,
              subjectId: value,
              name: value,
            );
            subjectCtrl.clear();
          },
          child: const Text("Create"),
        ),
      ],
    );
  }

  Widget _createSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Create Section"),
        TextField(
          controller: sectionCtrl,
          decoration: const InputDecoration(labelText: "Section title"),
        ),
        TextField(
          controller: sectionTypeCtrl,
          decoration: const InputDecoration(labelText: "Section type"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedCategoryId == null || selectedSubjectId == null) return;
            final title = sectionCtrl.text.trim();
            final type = sectionTypeCtrl.text.trim();
            if (title.isEmpty) return;

            await service.createSection(
              categoryId: selectedCategoryId!,
              subjectId: selectedSubjectId!,
              sectionId: title,
              title: title,
              type: type.isEmpty ? "General" : type,
            );
            sectionCtrl.clear();
          },
          child: const Text("Create"),
        ),
      ],
    );
  }

  Future<void> _editContent({
    required String itemId,
    required String currentTitle,
    required String currentType,
    required String currentData,
    required String currentSubheading,
  }) async {
    if (selectedCategoryId == null ||
        selectedSubjectId == null ||
        selectedSectionId == null) {
      return;
    }

    final titleCtrl = TextEditingController(text: currentTitle);
    final subheadingCtrl = TextEditingController(text: currentSubheading);
    final dataCtrl = TextEditingController(text: currentData);
    var selectedType = currentType;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text("Edit Content"),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(value: "note", child: Text("Note")),
                    DropdownMenuItem(value: "video", child: Text("Video")),
                    DropdownMenuItem(value: "image", child: Text("Image")),
                    DropdownMenuItem(value: "pdf", child: Text("PDF")),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setLocalState(() => selectedType = v);
                  },
                  decoration: const InputDecoration(labelText: "Content type"),
                ),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: selectedType == "note" ? "Heading" : "Title",
                  ),
                ),
                if (selectedType == "note")
                  TextField(
                    controller: subheadingCtrl,
                    decoration: const InputDecoration(
                      labelText: "Subheading (optional)",
                    ),
                  ),
                TextField(
                  controller: dataCtrl,
                  maxLines: selectedType == "note" ? 8 : 4,
                  decoration: InputDecoration(
                    labelText:
                        selectedType == "note" ? "Note body" : "Data / URL",
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final data = dataCtrl.text.trim();
                if (title.isEmpty || data.isEmpty) return;

                await service.updateItem(
                  categoryId: selectedCategoryId!,
                  subjectId: selectedSubjectId!,
                  sectionId: selectedSectionId!,
                  itemId: itemId,
                  title: title,
                  type: selectedType,
                  data: data,
                  subheading: selectedType == "note"
                      ? subheadingCtrl.text.trim()
                      : null,
                );

                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createContent() {
    final canAdd = selectedCategoryId != null &&
        selectedSubjectId != null &&
        selectedSectionId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Add Content"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: canAdd ? _promptAndCreateRichTextNote : null,
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text("Add Rich Text Note"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButton<String>(
          value: contentType,
          items: const [
            DropdownMenuItem(value: "note", child: Text("Note")),
            DropdownMenuItem(value: "video", child: Text("Video")),
            DropdownMenuItem(value: "image", child: Text("Image")),
            DropdownMenuItem(value: "pdf", child: Text("PDF")),
          ],
          onChanged: (v) => setState(() => contentType = v ?? "note"),
        ),
        TextField(
          controller: contentTitleCtrl,
          decoration: InputDecoration(
            labelText: contentType == "note" ? "Heading" : "Title",
          ),
        ),
        if (contentType == "note")
          TextField(
            controller: contentSubheadingCtrl,
            decoration: const InputDecoration(
              labelText: "Subheading (optional)",
            ),
          ),
        if (contentType != "note")
          const SizedBox.shrink(),
        TextField(
          controller: contentDataCtrl,
          maxLines: contentType == "note" ? 8 : 3,
          decoration: InputDecoration(
            labelText: contentType == "note" ? "Note body" : "Data / URL",
            alignLabelWithHint: true,
          ),
        ),
        ElevatedButton(
          onPressed: !canAdd
              ? null
              : () async {
                  final title = contentTitleCtrl.text.trim();
                  final data = contentDataCtrl.text.trim();
                  if (title.isEmpty || data.isEmpty) return;

                  await service.addContent(
                    categoryId: selectedCategoryId!,
                    subjectId: selectedSubjectId!,
                    sectionId: selectedSectionId!,
                    type: contentType,
                    title: title,
                    data: data,
                    subheading: contentType == "note"
                        ? contentSubheadingCtrl.text.trim()
                        : null,
                  );

                  contentTitleCtrl.clear();
                  contentSubheadingCtrl.clear();
                  contentDataCtrl.clear();
                },
          child: const Text("Add Content"),
        ),
      ],
    );
  }

  Widget _contentList() {
    if (selectedCategoryId == null ||
        selectedSubjectId == null ||
        selectedSectionId == null) {
      return const Text("Select category, subject, and section to manage content");
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: service.fetchItems(
        categoryId: selectedCategoryId!,
        subjectId: selectedSubjectId!,
        sectionId: selectedSectionId!,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text("No content items yet");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: docs.map((doc) {
            final row = doc.data();
            final title = (row['title'] ?? '').toString();
            final type = (row['type'] ?? '').toString();
            final subheading = (row['subheading'] ?? '').toString();
            final data = (row['data'] ?? '').toString();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? "(Untitled)" : title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (subheading.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subheading,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(type.isEmpty ? "unknown" : type),
                    const SizedBox(height: 10),
                    if (type == "note")
                      OutlinedButton.icon(
                        onPressed: () => _openRichTextEditor(
                          itemId: doc.id,
                          title: title,
                          subheading: subheading,
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text("Open In Rich Text Editor"),
                      ),
                    if (type == "note") const SizedBox(height: 8),
                    _actions(
                      onEdit: () => _editContent(
                        itemId: doc.id,
                        currentTitle: title,
                        currentType: type.isEmpty ? "note" : type,
                        currentData: data,
                        currentSubheading: subheading,
                      ),
                      onDelete: () async {
                        await service.deleteItem(
                          categoryId: selectedCategoryId!,
                          subjectId: selectedSubjectId!,
                          sectionId: selectedSectionId!,
                          itemId: doc.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ADMIN CMS DASHBOARD")),
      body: Row(
        children: [
          Container(
            width: 380,
            color: Colors.grey[200],
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                const Text(
                  "STRUCTURE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _categoryList(),
                const Divider(),
                _subjectList(),
                const Divider(),
                _sectionList(),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "ADMIN TOOLS",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _createCategory(),
                const SizedBox(height: 12),
                _createSubject(),
                const SizedBox(height: 12),
                _createSection(),
                const Divider(height: 24),
                _createContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}