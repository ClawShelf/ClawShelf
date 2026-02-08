import 'dart:convert';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:molt_manual/core/engine/isar/document.dart'; // Models
import 'package:molt_manual/core/engine/isar/app_config.dart'; // Models
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DocSyncManager {
  final Isar isar;
  static const remoteUrl =
      "https://your-user.github.io/molt-manual/master_doc.json";

  DocSyncManager(this.isar);

  /// --- THE MAIN INITIALIZER ---
  Future<void> initLocalData() async {
    final info = await PackageInfo.fromPlatform();
    final int packageBuild = int.parse(info.buildNumber);

    final meta = await isar.appMetadatas
        .filter()
        .keyEqualTo("synced_build")
        .findFirst();
    final int localBuild = meta?.value ?? 0;

    if (localBuild < packageBuild) {
      // 1. Load ALL asset files here
      final String docJson = await rootBundle.loadString(
        'assets/master_doc.json',
      );
      final String configJson = await rootBundle.loadString(
        'assets/app_config.json',
      );

      final dir = await getApplicationDocumentsDirectory();

      // 2. Offload everything to the worker
      await Isolate.run(
        () => _backgroundWorker(
          dir.path,
          docJson,
          configJson,
          packageBuild,
          null, // No remote hash for asset seed
        ),
      );
    }
  }

  void startBackgroundRemoteSync() {
    _checkForUpdates();
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

        // Background sync: only updates docs, leaves Nav/Redirects as-is
        await Isolate.run(
          () =>
              _backgroundWorker(dir.path, fullDoc.body, null, null, remoteHash),
        );
      }
    } catch (e) {
      print("Sync skipped: $e");
    }
  }
}

/// --- THE ISOLATE WORKER ---
Future<void> _backgroundWorker(
  String path,
  String docJson,
  String? configJson,
  int? build,
  String? hash,
) async {
  final workerIsar = await Isar.open(
    [DocEntrySchema, AppMetadataSchema, AppNavigationSchema, AppRedirectSchema],
    directory: path,
    name: 'default',
  );

  final docData = jsonDecode(docJson);
  final List docs = docData['docs'];
  final String finalHash = hash ?? md5.convert(utf8.encode(docJson)).toString();

  // 1. Parse Docs
  final docEntries = docs
      .map(
        (d) => DocEntry()
          ..docId = d['id']
          ..title = d['title'] ?? ""
          ..content = d['content'] ?? ""
          ..category = d['category'] ?? "General"
          ..emoji = d['emoji'] ?? "📝"
          ..lastUpdated = DateTime.now(),
      )
      .toList();

  // 2. Parse Config (Only if provided during local seed)
  List<AppNavigation>? navItems;
  List<AppRedirect>? redirects;

  if (configJson != null) {
    final configData = jsonDecode(configJson);

    // 1. Map Navigation (Recursive)
    navItems = ((configData['navigation'] as Map<String, dynamic>).keys).map((
      languageCode,
    ) {
      final navJson = configData['navigation'][languageCode];
      return AppNavigation()
        ..languageCode = languageCode
        ..tabs = (navJson as List).map((tabJson) {
          return NavTab()
            ..title = tabJson['tab_title']
            ..groups = (tabJson['groups'] as List).map((groupJson) {
              return NavGroup()
                ..title = groupJson['group_title']
                ..nodes = (groupJson['pages'] as List)
                    .map((nodeJson) => _mapNavNode(nodeJson))
                    .toList();
            }).toList();
        }).toList();
    }).toList();

    // 2. Map Redirects (Handling those 'late' fields)
    redirects = (configData['redirects'] as List).map((r) {
      return AppRedirect()
        ..source =
            r['source'] ??
            "" // FIX: Ensure late fields are set
        ..destination =
            r['destination'] ?? ""; // FIX: Ensure late fields are set
    }).toList();
  }

  // 3. ATOMIC WRITE
  workerIsar.writeTxnSync(() {
    workerIsar.docEntrys.clearSync();
    workerIsar.docEntrys.putAllSync(docEntries);

    if (navItems != null) {
      workerIsar.appNavigations.clearSync();
      workerIsar.appNavigations.putAllSync(navItems);
    }

    if (redirects != null) {
      workerIsar.appRedirects.clearSync();
      workerIsar.appRedirects.putAllSync(redirects);
    }

    if (build != null) {
      workerIsar.appMetadatas.putSync(
        AppMetadata()
          ..key = "synced_build"
          ..value = build,
      );
    }
    workerIsar.appMetadatas.putSync(
      AppMetadata()
        ..key = "docs_hash"
        ..valueString = finalHash,
    );
  });

  await workerIsar.close();
}

// Helper function for recursion
NavNode _mapNavNode(Map<String, dynamic> json) {
  return NavNode()
    ..type = json['type']
    ..title = json['title']
    ..path = json['path']
    ..children = json['children'] != null
        ? (json['children'] as List).map((child) => _mapNavNode(child)).toList()
        : null;
}
