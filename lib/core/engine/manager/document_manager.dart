import 'dart:convert';
import 'dart:io';
import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/constants/urls.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:claw_shelf/l10n/app_localizations.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:isar_plus/isar_plus.dart';

class DocSyncManager {
  static const String dbName = 'default';

  static void startBackgroundDownload(Isar isar, String targetPath) async {
    try {
      final manifestResponse = await http.get(Uri.parse(remoteVersionUrl));
      if (manifestResponse.statusCode != 200) return;

      final manifest = jsonDecode(manifestResponse.body);
      final int remoteTimestamp = manifest[MetadataKeys.bundleVersion];

      // Query local Isar using the SAME key used in the build.json
      final localMeta = isar.appMetadatas
          .where()
          .keyEqualTo(
            MetadataKeys.bundleVersion,
          ) // Use bundleVersion, not buildDate
          .findFirst();

      final int localTimestamp = localMeta?.valueInt ?? 0;

      if (remoteTimestamp > localTimestamp) {
        print("☁️ New bundle $remoteTimestamp found. Downloading...");
        final zipResponse = await http.get(
          Uri.parse(manifest[MetadataKeys.jsonZipUrl]),
        );

        if (zipResponse.statusCode == 200) {
          // Verify hash before staging
          final remoteHash = manifest[MetadataKeys.jsonIsarHash];

          final bool success = await compute(_verifyAndSave, {
            'bytes': zipResponse.bodyBytes,
            'hash': remoteHash,
            'path': '$targetPath/update.zip',
          });
          final l10n = await getL10n();
          if (success) {
            GetIt.instance<GlobalKey<ScaffoldMessengerState>>().currentState
                ?.showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.documentManagerUpdateDownloadedSnackBarMessage,
                    ),
                  ),
                );
          }
        }
      }
    } catch (e) {
      print("⚠️ Background sync error: $e");
    }
  }
}

Future<AppLocalizations> getL10n() async {
  // 1. Get current language from your Isar-backed repository
  final langCodeRecord = GetIt.I<SettingsRepository>().getLanguage();

  // 2. Manually load the generated localizations for that locale
  return await AppLocalizations.delegate.load(
    Locale(langCodeRecord.stringValue!),
  );
}

// 1. The "Heavy Lifter" function (Runs in Isolate)
// We pass a Map because compute only takes one argument.
Future<bool> _verifyAndSave(Map<String, dynamic> params) async {
  final Uint8List bytes = params['bytes'];
  final String expectedHash = params['hash'];
  final String filePath = params['path'];

  // Heavy CPU work: Hashing
  final String actualHash = sha256.convert(bytes).toString();

  print("Expected hash $expectedHash, downloaded hash $actualHash");

  if (actualHash == expectedHash) {
    // Heavy I/O work: Writing to disk
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return true;
  }
  return false;
}
