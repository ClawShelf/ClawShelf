import 'dart:io';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

class DocProcessor {
  final Isar isar;
  final String docsRoot;
  final String imageDest;

  DocProcessor({
    required this.isar,
    required this.docsRoot,
    required this.imageDest,
  });

  /// The main entry point to sync the entire folder to Isar
  Future<void> syncAll() async {
    final dir = Directory(docsRoot);
    if (!await dir.exists()) {
      throw Exception("Docs root not found at $docsRoot");
    }

    final List<DocEntry> entries = [];
    final stopwatch = Stopwatch()..start();

    // 1. Walk through the directory for .md files
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && p.extension(entity.path) == '.md') {
        final relativePath = p.relative(entity.path, from: docsRoot);
        final entry = await _processFile(entity, relativePath);
        entries.add(entry);
      }
    }

    // 2. Perform Batch Write
    await isar.writeTxn(() async {
      // Upsert all processed documents
      // await isar.docEntrys.putAll(entries);
      for (var x in entries) {
        try {
          await isar.docEntrys.put(x);
        } catch (e) {
          print("Error writting: $e");
        }
      }

      // Update Metadata to track when the last sync happened
      final syncMeta = AppMetadata()
        ..key = "last_docs_sync"
        ..value = DateTime.now().millisecondsSinceEpoch
        ..valueString = "Version: ${DateTime.now().toIso8601String()}";

      await isar.appMetadatas.put(syncMeta);
    });

    stopwatch.stop();
    print(
      "✅ Synced ${entries.length} documents in ${stopwatch.elapsedMilliseconds}ms",
    );
  }

  Future<DocEntry> _processFile(File file, String relativePath) async {
    final rawContent = await file.readAsString();
    final stats = await file.lastModified();

    // 1. Metadata Extraction (YAML + Fallbacks)
    final extraction = _extractMetadata(rawContent, relativePath);
    final meta = extraction['meta'] as Map<String, dynamic>;

    // 2. Image Syncing & Markdown Cleaning
    final finalContent = _syncImages(
      extraction['content'] as String,
      relativePath,
    );

    return DocEntry()
      ..docId = relativePath
          .replaceAll(RegExp(r'/|\\'), '_')
          .replaceAll('.md', '')
      ..docPath = relativePath
      ..content = finalContent
      ..title = meta['title']
      ..emoji = meta['emoji'] ?? "📄"
      ..category = meta['category']
      ..lang = meta['lang']
      ..readWhen = meta['read_when']
      ..summary = meta['summary']
      ..lastUpdated = stats;
  }

  String _syncImages(String content, String relativeFilePath) {
    var workingContent = content;

    // Matches both <img src="..."> and ![alt](path)
    final imgPattern = RegExp(r'<(img|!\[)[^>]*?(src="|\]\()([^"> \)]+)');

    workingContent = workingContent.replaceAllMapped(imgPattern, (match) {
      final oldSrc = match.group(3)!;

      // Skip network images
      if (oldSrc.startsWith(RegExp(r'http|https|data:'))) {
        return match.group(0)!;
      }

      final newFilename = _copyAndHashImage(oldSrc, relativeFilePath);

      // Reconstruct the tag with the flattened image path
      if (match.group(1) == 'img') {
        return '<img src="$newFilename"';
      } else {
        // Keeps the existing Alt text if present
        return '![${match.group(2)!.replaceAll('](', '')}]($newFilename';
      }
    });

    // Strip Mintlify-specific UI wrappers that aren't standard Markdown
    final customTags = [
      'Columns',
      'CardGroup',
      'Steps',
      'AccordionGroup',
      'Tabs',
      'Card',
    ];
    for (var tag in customTags) {
      workingContent = workingContent.replaceAll(RegExp('</?$tag[^>]*>'), '');
    }

    return workingContent;
  }

  String _copyAndHashImage(String originalImgPath, String relativeFilePath) {
    final mdDir = p.dirname(p.join(docsRoot, relativeFilePath));
    final searchPath = originalImgPath.replaceFirst('/', '');

    var fullSrcPath = p.normalize(p.join(mdDir, originalImgPath));
    if (!File(fullSrcPath).existsSync()) {
      fullSrcPath = p.normalize(p.join(docsRoot, searchPath));
    }

    final srcFile = File(fullSrcPath);
    if (srcFile.existsSync()) {
      final imgFilename = p.basename(fullSrcPath);
      final destPath = p.join(imageDest, imgFilename);
      final destFile = File(destPath);

      // Only copy if file is new or modified (hash check)
      if (!destFile.existsSync() || _getHash(srcFile) != _getHash(destFile)) {
        Directory(imageDest).createSync(recursive: true);
        srcFile.copySync(destPath);
      }
      return imgFilename;
    }
    return originalImgPath;
  }

  String _getHash(File file) => md5.convert(file.readAsBytesSync()).toString();

  Map<String, dynamic> _extractMetadata(String content, String relativePath) {
    final parts = relativePath.replaceAll('\\', '/').split('/');

    // Logic: If path starts with zh-CN, lang is zh. Otherwise en.
    String lang = parts[0] == 'zh-CN' ? 'zh' : 'en';

    // Category is usually the folder name
    String category = parts.length > (lang == 'zh' ? 2 : 1)
        ? parts[lang == 'zh' ? 1 : 0]
        : 'general';

    final yamlPattern = RegExp(r'^---\s*\n(.*?)\n---\s*\n', dotAll: true);
    final match = yamlPattern.firstMatch(content);

    Map<String, dynamic> meta = {
      "title": p
          .basenameWithoutExtension(relativePath)
          .replaceAll(RegExp(r'[-_]'), ' '),
      "category": category,
      "lang": lang,
      "read_when": <String>[],
    };

    String cleanContent = content;
    if (match != null) {
      final rawYaml = match.group(1)!;
      try {
        final yaml = loadYaml(rawYaml);
        if (yaml is YamlMap) {
          yaml.forEach((k, v) {
            if (k == 'read_when') {
              if (v is YamlList) {
                // Convert YamlList to a standard List<String>
                meta[k] = v.map((item) => item.toString()).toList();
              } else if (v is String) {
                meta[k] = [v];
              } else {
                meta[k] = <String>[];
              }
            } else {
              meta[k] = v;
            }
          });
        }
      } catch (e) {
        // FALLBACK: If YAML is malformed due to colons in bullets
        print(
          "⚠️ YAML parse failed for $relativePath, attempting regex fallback.",
        );

        // Look specifically for read_when block and grab lines starting with '-'
        final readWhenRegex = RegExp(r'read_when:\s*\n((?:\s*- .*\n?)+)');
        final rwMatch = readWhenRegex.firstMatch(rawYaml);

        if (rwMatch != null) {
          final lines = rwMatch
              .group(1)!
              .split('\n')
              .map((s) => s.trim())
              .where((s) => s.startsWith('-'))
              .map((s) => s.replaceFirst('-', '').trim())
              .toList();
          meta['read_when'] = lines;
        }
      }
      cleanContent = content.substring(match.end).trim();
    }

    return {"meta": meta, "content": cleanContent};
  }
}
