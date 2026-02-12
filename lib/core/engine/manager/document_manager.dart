import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';

const docsIsarKey = 'docs_db';

class DocSyncManager {
  late Isar isar;
  final String dbName = 'default';

  // Update these URLs to your actual endpoints
  static const remoteVersionUrl = "https://your-server.com/docs/version.json";
  static const remoteDbBaseUrl = "https://your-server.com/docs/";

  DocSyncManager(this.isar);

  /// 🚀 BOOTSTRAP: Call this in your main()
  static Future<Isar> bootstrap() async {
    final dir = await getApplicationDocumentsDirectory();
    final localDbFile = File('${dir.path}/default.isar');

    // 1. Get Build Number of the App itself (from pubspec.yaml)
    final info = await PackageInfo.fromPlatform();
    final packageBuild = int.parse(info.buildNumber);

    // 2. Peek at the Local DB build number WITHOUT opening the full Isar yet
    // We use a small sidecar file or a metadata-only Isar peek
    final localBuild = await _readLocalMetadataBuild(dir.path);

    // 3. DECISION: Is the Package (Store Update) newer than our Local Data?
    if (!(await localDbFile.exists()) || packageBuild > localBuild) {
      print(
        "📦 Package (v$packageBuild) is newer than Local (v$localBuild). Seeding...",
      );
      final data = await rootBundle.load('assets/default.isar');
      await localDbFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    // 4. Open the winning database
    return await Isar.open(
      [
        DocEntrySchema,
        AppMetadataSchema,
        AppNavigationSchema,
        AppRedirectSchema,
        AppImageSchema,
      ],
      name: 'default',
      directory: dir.path,
    );
  }

  /// 🌐 REMOTE SYNC: Call this after app is loaded
  Future<void> syncWithRemote() async {
    try {
      // 1. Fetch the remote manifest
      final response = await http.get(Uri.parse(remoteVersionUrl));
      if (response.statusCode != 200) return;

      final remoteJson = jsonDecode(response.body);
      final remoteBuild = remoteJson['build_number'];
      final remoteHash = remoteJson['hash'];

      // 2. Check current Local state
      final localMeta = await isar.appMetadatas
          .filter()
          .keyEqualTo("build_number")
          .findFirst();
      final localBuild = localMeta?.value ?? 0;
      final localHash = localMeta?.valueString ?? "";

      // 3. Comparison Logic
      if (remoteBuild > localBuild && remoteHash != localHash) {
        print("☁️ Remote (v$remoteBuild) is newer. Downloading binary...");
        await _downloadAndReplace(
          remoteJson['db_filename'],
          remoteBuild,
          remoteHash,
        );
      }
    } catch (e) {
      print("⚠️ Remote sync skipped: $e");
    }
  }

  /// 🔄 THE SWAP: Safe replacement of the binary file
  Future<void> _downloadAndReplace(
    String filename,
    int build,
    String hash,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final tempFile = File('${dir.path}/$dbName.isar.tmp');
    final currentDbFile = File('${dir.path}/$dbName.isar');

    // 1. Download binary
    final response = await http.get(Uri.parse("$remoteDbBaseUrl$filename"));
    await tempFile.writeAsBytes(response.bodyBytes);

    // 2. Atomic Swap
    await isar.close();
    if (await currentDbFile.exists()) await currentDbFile.delete();
    await tempFile.rename(currentDbFile.path);

    // 3. Re-open and stamp metadata
    isar = await Isar.open(
      [
        DocEntrySchema,
        AppMetadataSchema,
        AppNavigationSchema,
        AppRedirectSchema,
        AppImageSchema,
      ],
      name: dbName,
      directory: dir.path,
    );

    await isar.writeTxn(() async {
      await isar.appMetadatas.put(
        AppMetadata()
          ..key = "build_number"
          ..value = build,
      );
      await isar.appMetadatas.put(
        AppMetadata()
          ..key = "docs_hash"
          ..valueString = hash,
      );
    });
  }

  /// Helper to peek at metadata without opening full Isar (uses a tiny separate file)
  static Future<int> _readLocalMetadataBuild(String path) async {
    final metaFile = File('$path/build_marker.txt');
    if (!await metaFile.exists()) return 0;
    return int.tryParse(await metaFile.readAsString()) ?? 0;
  }
}
