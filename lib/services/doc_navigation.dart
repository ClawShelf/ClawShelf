import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/screens/doc_content.dart';

class CSDocNavigation {
  static void open(BuildContext context, Isar isar, DocEntry doc) {
    // 1. Centralized Update Logic
    // We don't 'await' here so the UI transitions immediately
    isar.writeTxn(() async {
      doc.lastAccessed = DateTime.now();
      await isar.docEntrys.put(doc);
    });

    // 2. Centralized Routing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CSDocContentPage(id: doc.id, isar: isar),
      ),
    );
  }

  static DocEntry? findDocByPath(String path, Isar isar) {
    if (path.isEmpty) return null;

    // 1. Normalize the path
    // Remove leading/trailing slashes and lower-case it
    String cleanPath = path.toLowerCase().trim();
    if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
    if (cleanPath.endsWith('/')) {
      cleanPath = cleanPath.substring(0, cleanPath.length - 1);
    }
    cleanPath = cleanPath.replaceAll('/', '_');

    // 3. Find the matching document
    // We check if the docPath ends with our link or matches it without .md
    final targetDoc = isar.docEntrys.filter().anyOf([
      cleanPath,
      "${cleanPath}_index",
    ], (db, p) => db.docIdEqualTo(p)).findFirstSync();

    return targetDoc;
  }

  static void navigateToDoc(BuildContext context, String path, Isar isar) {
    final targetDoc = findDocByPath(path, isar);

    if (targetDoc != null) {
      open(context, isar, targetDoc);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Document not found: $path")));
    }
  }
}
