import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:crypto/crypto.dart';

// Configuration
const String docsRoot = './openclaw/docs';
const String imageDest = './assets/images';
const String outputFile = './assets/master_doc.json';

// Simple helper for MD5 hashing
String getFileHash(File file) {
  return md5.convert(file.readAsBytesSync()).toString();
}

String processMatch(String originalImgPath, String relativeFilePath) {
  if (originalImgPath.startsWith(RegExp(r'http|https|data:'))) {
    return originalImgPath;
  }

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

    // Sync image if hash differs or doesn't exist
    if (!destFile.existsSync() || getFileHash(srcFile) != getFileHash(destFile)) {
      Directory(imageDest).createSync(recursive: true);
      srcFile.copySync(destPath);
    }
    return imgFilename;
  }
  return originalImgPath;
}

String syncAndFlattenImages(String content, String relativeFilePath) {
  var workingContent = content;

  // 1. Process HTML <img> Tags
  final htmlImgPattern = RegExp(r'<img\s+[^>]*?src="([^"]+)"[^>]*?>');
  workingContent = workingContent.replaceAllMapped(htmlImgPattern, (match) {
    final fullTag = match.group(0)!;
    final oldSrc = match.group(1)!;
    final newFilename = processMatch(oldSrc, relativeFilePath);

    if (fullTag.contains('dark:hidden')) return "\n\n![Logo]($newFilename)\n\n";
    if (fullTag.contains('dark:block')) return "";
    return "\n\n![Image]($newFilename)\n\n";
  });

  // 2. Process Standard Markdown Images
  final mdImgPattern = RegExp(r'!\[(.*?)\]\((.*?)\)');
  workingContent = workingContent.replaceAllMapped(mdImgPattern, (match) {
    return "![${match.group(1)}](${processMatch(match.group(2)!, relativeFilePath)})";
  });

  // 3. Set Images Free (Remove wrappers)
  final trappedImgPattern = RegExp(r'<(p|div)[^>]*?>\s*(!\[.*?\]\(.*?\))\s*</(p|div)>');
  workingContent = workingContent.replaceAll(trappedImgPattern, '\n\n\$2\n\n');

  // 4. Transpile Mintlify tags
  final silentWrappers = ['Columns', 'CardGroup', 'Steps', 'AccordionGroup', 'Tabs'];
  for (var tag in silentWrappers) {
    workingContent = workingContent.replaceAll(RegExp('</?$tag[^>]*>'), '');
  }
  
  // Escape placeholders like <id>
  workingContent = workingContent.replaceAllMapped(
    RegExp(r'(?<!`|<)<([a-z0-9_-]+)>(?!`|>)'), 
    (m) => '`<${m.group(1)}>`'
  );

  return workingContent;
}

Map<String, dynamic> extractMetadata(String content, String relativePath) {
  final parts = relativePath.replaceAll('\\', '/').split('/');
  String lang = 'en';
  String category = 'general';

  if (parts[0] == 'zh-CN') {
    lang = 'zh';
    category = parts.length > 2 ? parts[1] : 'general';
  } else {
    category = parts.length > 1 ? parts[0] : 'general';
  }

  if (category.contains('.')) category = 'general';

  final filename = parts.last;
  Map<String, dynamic> metadata = {
    "title": filename.replaceAll('.md', '').split(RegExp(r'(?=[A-Z])|_|-')).join(' '),
    "emoji": "📄",
    "category": category,
    "lang": lang,
    "read_when": []
  };

  // YAML Extraction
  final yamlPattern = RegExp(r'^---\s*\n(.*?)\n---\s*\n', dotAll: true);
  final yamlMatch = yamlPattern.firstMatch(content);
  String cleanContent = content;

  if (yamlMatch != null) {
    try {
      final yamlData = loadYaml(yamlMatch.group(1)!);
      if (yamlData is YamlMap) {
        yamlData.forEach((k, v) {
          if (k == "read_when") {
             metadata["read_when"] = v is String ? [v] : (v as List).toList();
          } else {
             metadata[k.toString()] = v;
          }
        });
      }
      cleanContent = content.substring(yamlMatch.end).trim();
    } catch (e) { /* ignore yaml errors */ }
  }

  // H1 Fallback
  final h1Pattern = RegExp(r'^#\s+(.*)', multiLine: true);
  final h1Match = h1Pattern.firstMatch(cleanContent);
  if (h1Match != null && metadata["title"] != h1Match.group(1)!.trim()) {
    metadata["title"] = h1Match.group(1)!.trim();
  }

  return {"meta": metadata, "content": cleanContent};
}

void main() async {
  final List<Map<String, dynamic>> docEntries = [];
  final dir = Directory(docsRoot);

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && p.extension(entity.path) == '.md') {
      final relativePath = p.relative(entity.path, from: docsRoot);
      final rawContent = await entity.readAsString();

      final extraction = extractMetadata(rawContent, relativePath);
      final finalContent = syncAndFlattenImages(extraction["content"], relativePath);

      docEntries.add({
        "id": relativePath.replaceAll(RegExp(r'/|\\'), '_').replaceAll('.md', ''),
        "path": relativePath,
        "content": finalContent,
        ...extraction["meta"]
      });
    }
  }

  final masterData = {
    "version": DateTime.now().toIso8601String(),
    "docs": docEntries
  };

  File(outputFile).writeAsStringSync(jsonEncode(masterData));
  print("✅ Processed ${docEntries.length} files into $outputFile");
}