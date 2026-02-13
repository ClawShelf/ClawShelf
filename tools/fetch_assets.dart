import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:claw_shelf/core/constants/urls.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

// Run: dart run tool/fetch_assets.dart
void main() async {
  const String targetDir = 'assets'; // Your app's assets folder

  print("🌐 Checking for latest documentation bundle...");

  try {
    // 1. Get Manifest
    final response = await http.get(Uri.parse(remoteVersionUrl));
    if (response.statusCode != 200) throw "Failed to fetch build.json";

    final manifest = jsonDecode(response.body);
    final String zipUrl = manifest['zip_url'];
    final String remoteHash = manifest['isar_hash'];

    print("📦 Found Version: ${manifest['version']}. Downloading...");

    // 2. Download ZIP
    final zipResponse = await http.get(Uri.parse(zipUrl));
    if (zipResponse.statusCode != 200) throw "Failed to download ZIP";
    final zipBytes = zipResponse.bodyBytes;

    // 3. Verify Hash
    final localHash = sha256.convert(zipBytes).toString();
    if (localHash != remoteHash) {
      throw "❌ Integrity Check Failed! Hash mismatch.\nExpected: $remoteHash\nGot:      $localHash";
    }
    print("✅ Integrity verified.");

    // 4. Extract
    print("📂 Extracting to $targetDir...");
    final archive = ZipDecoder().decodeBytes(zipBytes);

    for (final file in archive) {
      final filename = file.name;
      final data = file.content as List<int>;
      final outFile = File(join(targetDir, filename));

      if (file.isFile) {
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(data);
      } else {
        Directory(outFile.path).createSync(recursive: true);
      }
    }

    print("🎉 Success! Assets are ready for building the app.");
  } catch (e) {
    print("❌ Error: $e");
    exit(1);
  }
}
