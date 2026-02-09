import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/services/doc_navigation.dart';

class CSCategoryListPage extends StatelessWidget {
  final Isar isar;
  final List<String> categories;
  final String lang;
  final String title;

  const CSCategoryListPage({
    super.key,
    required this.isar,
    required this.categories,
    required this.lang,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)), // Uses your custom title
      body: FutureBuilder<List<DocEntry>>(
        future: isar.docEntrys
            .filter()
            .langEqualTo(lang)
            .and()
            .anyOf(categories, (db, list) => db.categoryEqualTo(list))
            .sortByTitle()
            .findAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No documents found."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return ListTile(
                leading: Text(doc.emoji ?? "📄"),
                title: Text(doc.title ?? "Untitled"),
                subtitle: Text(doc.docId ?? ""),
                onTap: () => _openDoc(context, doc),
              );
            },
          );
        },
      ),
    );
  }

  void _openDoc(BuildContext context, DocEntry doc) {
    // Logic to update lastAccessed and navigate
    CSDocNavigation.open(context, isar, doc);
  }
}
