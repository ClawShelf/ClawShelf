import 'dart:io';
import 'dart:convert';
import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/constants/urls.dart';
import 'package:claw_shelf/services/sync_logic.dart';
import 'package:http/http.dart' as http;

// Run: dart run tool/fetch_assets.dart
void main() async {
  const String targetDir = 'assets'; // Your app's assets folder

  print("🌐 Checking for latest documentation bundle...");

  try {
    // 1. Get Manifest
    final response = await http.get(Uri.parse(remoteVersionUrl));
    if (response.statusCode != 200) throw "Failed to fetch build.json";

    final manifest = jsonDecode(response.body);
    final String zipUrl = manifest[MetadataKeys.jsonZipUrl];
    final String remoteHash = manifest[MetadataKeys.jsonIsarHash];

    print(
      "📦 Found Version: ${manifest[MetadataKeys.bundleVersion]}. Downloading...",
    );

    // 2. Download ZIP
    final zipResponse = await http.get(Uri.parse(zipUrl));
    if (zipResponse.statusCode != 200) throw "Failed to download ZIP";
    final zipBytes = zipResponse.bodyBytes;

    await SyncLogic.processBundle(
      zipBytes: zipBytes,
      expectedHash: remoteHash,
      targetPath: targetDir,
    );

    print("🎉 Success! Assets are ready for building the app.");
  } catch (e) {
    print("❌ Error: $e");
    exit(1);
  }
}
