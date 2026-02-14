import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';

class SyncLogic {
  /// Shared extraction and verification logic
  static Future<void> processBundle({
    required List<int> zipBytes,
    required String expectedHash,
    required String targetPath,
  }) async {
    // 1. Verify Hash (Shared Integrity Check)
    final localHash = sha256.convert(zipBytes).toString();
    if (localHash != expectedHash) {
      throw Exception("Integrity Check Failed! Hash mismatch.");
    }

    // 2. Clear & Extract
    final directory = Directory(targetPath);
    if (directory.existsSync()) {
      // Be careful: In the app, you might want to only delete specific subfolders
      directory.deleteSync(recursive: true);
    }
    directory.createSync(recursive: true);

    final archive = ZipDecoder().decodeBytes(zipBytes);
    for (final file in archive) {
      final path = "$targetPath/${file.name}";
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path).createSync(recursive: true);
      }
    }
  }
}