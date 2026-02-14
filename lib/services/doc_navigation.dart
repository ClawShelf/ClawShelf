import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/screens/doc_content.dart';

class CSDocNavigation {
  static void open(BuildContext context, DocEntry doc) {
    final settingsRepo = GetIt.instance<SettingsRepository>();

    // We don't 'await' here so the UI transitions immediately
    settingsRepo.addToHistory(doc);

    // 2. Centralized Routing
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CSDocContentPage(id: doc.id)),
    );
  }

  static DocEntry? findDocByPath(String path) {
    if (path.isEmpty) return null;

    final docsIsar = GetIt.instance<Isar>(instanceName: MetadataKeys.docsIsarKey);

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
    final targetDoc = docsIsar.docEntrys.filter().anyOf([
      cleanPath,
      "${cleanPath}_index",
    ], (db, p) => db.docIdEqualTo(p)).findFirstSync();

    return targetDoc;
  }

  static void navigateToDoc(BuildContext context, String path) {
    final targetDoc = findDocByPath(path);

    if (targetDoc != null) {
      open(context, targetDoc);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Document not found: $path")));
    }
  }
}
