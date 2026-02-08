import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:molt_manual/core/engine/isar/document.dart';
import 'package:molt_manual/screens/doc_content.dart';

class MMDocNavigation {
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
        builder: (context) => DocContentPage(id: doc.id, isar: isar),
      ),
    );
  }
}
