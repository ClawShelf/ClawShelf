import 'dart:convert';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:molt_manual/core/engine/isar/document.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DocSyncManager {
  final Isar isar;
  static const remoteUrl =
      "https://your-user.github.io/molt-manual/master_doc.json";

  DocSyncManager(this.isar);

  /// Called by the Seed Screen (Blocks UI)
  Future<void> initLocalData() async {
    final info = await PackageInfo.fromPlatform();
    final int packageBuild = int.parse(info.buildNumber);

    final meta = await isar.appMetadatas
        .filter()
        .keyEqualTo("synced_build")
        .findFirst();

    if ((meta?.value ?? 0) < packageBuild) {
      final json = await rootBundle.loadString('assets/master_doc.json');
      final dir = await getApplicationDocumentsDirectory();

      // We pass the PATH, not the Isar instance
      await Isolate.run(
        () => _backgroundWorker(dir.path, json, packageBuild, null),
      );
    }
  }

  /// Called by the Main Page (Background)
  void startBackgroundRemoteSync() {
    // _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final response = await http.head(Uri.parse(remoteUrl));
      final String remoteHash =
          response.headers['etag']?.replaceAll('"', '') ?? "";

      final meta = await isar.appMetadatas
          .filter()
          .keyEqualTo("docs_hash")
          .findFirst();

      if (meta?.valueString != remoteHash) {
        final fullDoc = await http.get(Uri.parse(remoteUrl));
        final dir = await getApplicationDocumentsDirectory();

        await Isolate.run(
          () => _backgroundWorker(dir.path, fullDoc.body, null, remoteHash),
        );
      }
    } catch (e) {
      print("Remote sync skipped: $e");
    }
  }
}

/// The Isolate Worker: Re-opens Isar and performs the import
Future<void> _backgroundWorker(
  String path,
  String json,
  int? build,
  String? hash,
) async {
  // 1. Re-open Isar in the new isolate using the same schemas and name
  final workerIsar = await Isar.open(
    [DocEntrySchema, AppMetadataSchema],
    directory: path,
    name: 'default', // Matches your main instance name
  );

  try {
    // 2. Perform the logic
    await _performImportLogic(workerIsar, json, build, hash);
  } catch (e) {
    print("Import Failed: $e");
  }

  // 3. Close the instance for this isolate before it exits
  await workerIsar.close();
}

Future<void> _performImportLogic(
  Isar db,
  String json,
  int? build,
  String? hash,
) async {
  final data = jsonDecode(json);
  final List docs = data['docs'];
  final String finalHash = hash ?? md5.convert(utf8.encode(json)).toString();

  final entries = docs
      .map(
        (d) => DocEntry()
          ..docId = d['id']
          ..title = d['title']
          ..content = d['content'],
      )
      .toList();

  // Using sync transaction inside the isolate is often faster
  db.writeTxnSync(() {
    db.docEntrys.clearSync();
    db.docEntrys.putAllSync(entries);

    if (build != null) {
      db.appMetadatas.putSync(
        AppMetadata()
          ..key = "synced_build"
          ..value = build,
      );
    }

    db.appMetadatas.putSync(
      AppMetadata()
        ..key = "docs_hash"
        ..valueString = finalHash,
    );
  });
}
