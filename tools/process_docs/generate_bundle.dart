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
      await isar.docEntrys.putAll(entries);
      // for (var x in entries) {
      //   try {
      //     await isar.docEntrys.put(x);
      //   } catch (e) {
      //     print("Error writting: $e");
      //   }
      // }
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
      ..docId =
          relativePath.replaceAll(RegExp(r'/|\\'), '_').replaceAll('.md', '')
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

    // 1. HTML <img> Tag Logic (Transpiles to Markdown like your Python script)
    // Python: html_img_pattern = r'<img\s+[^>]*?src="([^"]+)"[^>]*?>'
    final htmlImgPattern = RegExp(
      r'<img\s+[^>]*?src="([^"]+)"[^>]*?>',
      dotAll: true, // Crucial in Dart for multi-line tags
      caseSensitive: false,
    );

    workingContent = workingContent.replaceAllMapped(htmlImgPattern, (match) {
      final fullTag = match.group(0)!;
      final oldSrc = match.group(1)!;

      if (oldSrc.startsWith(RegExp(r'http|https|data:'))) return fullTag;

      // Process the image (copy/hash)
      final normalizedSrc =
          oldSrc.startsWith('/') ? oldSrc.substring(1) : oldSrc;
      final newFilename = _copyAndHashImage(normalizedSrc, relativeFilePath);

      // Python Logic: Convert to Markdown + Handle Dark Mode
      if (fullTag.contains('dark:hidden')) {
        return "\n\n![Logo]($newFilename)\n\n";
      } else if (fullTag.contains('dark:block')) {
        return ""; // Hide the dark-mode version for the mobile app MVP
      }

      return "\n\n![Image]($newFilename)\n\n";
    });

    // 2. Standard Markdown ![alt](path)
    // Python: md_img_pattern = r'!\[(.*?)\]\((.*?)\)'
    final mdImgPattern = RegExp(r'!\[(.*?)\]\((.*?)\)');
    workingContent = workingContent.replaceAllMapped(mdImgPattern, (match) {
      final altText = match.group(1)!;
      final oldSrc = match.group(2)!;

      if (oldSrc.startsWith(RegExp(r'http|https|data:')))
        return match.group(0)!;

      final normalizedSrc =
          oldSrc.startsWith('/') ? oldSrc.substring(1) : oldSrc;
      final newFilename = _copyAndHashImage(normalizedSrc, relativeFilePath);

      return "![$altText]($newFilename)";
    });

    // 3. "Set the Images Free" (Remove <p> or <div> wrappers)
    // Python: trapped_img_pattern = r'<(p|div)[^>]*?>\s*(!\[.*?\]\(.*?\))\s*</(p|div)>'
    final trappedImgPattern = RegExp(
      r'<(p|div)[^>]*?>\s*(!\[.*?\]\(.*?\))\s*</(p|div)>',
      dotAll: true,
    );
    workingContent =
        workingContent.replaceAllMapped(trappedImgPattern, (match) {
      return "\n\n${match.group(2)}\n\n";
    });

    // 4. Transpile Mintlify (Strip silent wrappers)
    final silentWrappers = [
      'Columns',
      'CardGroup',
      'Steps',
      'Step',
      'AccordionGroup',
      'Tabs',
      // 'Card'
    ];
    for (var tag in silentWrappers) {
      workingContent =
          workingContent.replaceAll(RegExp('</?$tag[^>]*?>', dotAll: true), '');
    }

    // 5. Escape placeholders (Python: <id> -> `<id>`)
    workingContent = workingContent.replaceAllMapped(
      RegExp(r'(?<!`|<)<([a-z0-9_-]+)>(?!`|>)'),
      (match) => '`<${match.group(1)}>`',
    );

    // After stripping silent wrappers, clean up indentation for custom tags
    final customTagsWithBuilders = ['Card', 'Step'];

    for (var tag in customTagsWithBuilders) {
      // This regex finds the tag even if it has leading spaces/tabs and moves it to a new line
      workingContent = workingContent.replaceAllMapped(
          RegExp('^[ \t]*<(/?$tag[^>]*?)>', multiLine: true),
          (match) => '\n<${match.group(1)}>\n');
    }
    return workingContent;
  }

  String _copyAndHashImage(String originalImgPath, String relativeFilePath) {
    // 1. Normalize the input path (remove leading slash, handle backslashes)
    final cleanSrc =
        originalImgPath.replaceFirst(RegExp(r'^/'), '').replaceAll('\\', '/');

    // 2. Location A: Relative to the Markdown file
    final mdDir = p.dirname(p.join(docsRoot, relativeFilePath));
    final relativePath = p.normalize(p.join(mdDir, cleanSrc));

    // 3. Location B: Relative to the Docs Root (Fallback)
    final rootPath = p.normalize(p.join(docsRoot, cleanSrc));

    // 4. Location C: Project Root (Often where /assets/ lives in Mintlify)
    // Since docsRoot is likely 'openclaw/docs', we go up one level
    final projectRoot = p.dirname(docsRoot);
    final assetPath = p.normalize(p.join(projectRoot, cleanSrc));

    File? srcFile;
    if (File(relativePath).existsSync()) {
      srcFile = File(relativePath);
    } else if (File(rootPath).existsSync()) {
      srcFile = File(rootPath);
    } else if (File(assetPath).existsSync()) {
      srcFile = File(assetPath);
    }

    if (srcFile != null) {
      final imgFilename = p.basename(srcFile.path);
      final destPath = p.join(imageDest, imgFilename);
      final destFile = File(destPath);

      if (!destFile.existsSync() || _getHash(srcFile) != _getHash(destFile)) {
        Directory(imageDest).createSync(recursive: true);
        srcFile.copySync(destPath);
      }
      return imgFilename;
    }

    // If we reach here, the image wasn't found (this is why your count is low)
    print(
        "⚠️ Image not found: $originalImgPath (tried $relativePath, $rootPath, $assetPath)");
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
      // if (meta['title'] == null || meta['title'].isEmpty) {
      //   final h1Match =
      //       RegExp(r'^#\s+(.*)', multiLine: true).firstMatch(cleanContent);
      //   if (h1Match != null) {
      //     meta['title'] = h1Match.group(1)!.trim();
      //   }
      // }
    }

    return {"meta": meta, "content": cleanContent};
  }
}
