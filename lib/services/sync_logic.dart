import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';

class SyncLogic {
  static Future<void> processBundle({
    required List<int> zipBytes,
    required String targetPath,
    String? expectedHash,
  }) async {
    // 1. Hash check (only if requested)
    if (expectedHash != null && expectedHash.isNotEmpty) {
      final localHash = sha256.convert(zipBytes).toString();
      if (localHash != expectedHash) throw Exception("Hash mismatch");
    }

    // 2. TARGETED CLEANUP
    // We only delete what we are about to replace to avoid losing the zip itself!
    final imageDir = Directory('$targetPath/images');
    if (imageDir.existsSync()) {
      imageDir.deleteSync(recursive: true);
    }

    // List of Isar-related files to clear
    final isarFiles = [
      '$targetPath/default.isar',
      '$targetPath/default.isar.lock',
      '$targetPath/default.isar.management',
    ];
    for (var path in isarFiles) {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    }

    // 3. Extracting
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
