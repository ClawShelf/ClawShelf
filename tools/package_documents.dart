import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/args.dart';
import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/constants/urls.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'process_docs/generate_bundle.dart';
import 'process_docs/parse_docs_config.dart';
import 'package:path/path.dart';

/*
dart run tools/package_documents.dart --openclaw_path ~/openclaw --output assets
*/

void main(List<String> arguments) async {
  var parser = ArgParser()
    ..addOption('openclaw_path', help: 'Path to openclaw repository')
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output folder (e.g., assets)',
      defaultsTo: 'assets',
    )
    ..addOption(
      'isar_name',
      help: 'Isar database file name',
      defaultsTo: 'default',
    )
    ..addOption('openclaw_sha', help: 'The specific commit hash of the docs')
    ..addFlag(
      'archive',
      abbr: 'a',
      negatable: false,
      help: 'Create ZIP bundle and build.json in dist/',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');

  ArgResults argParseResult;
  String openClawPath;

  argParseResult = parser.parse(arguments);

  final bool shouldArchive = argParseResult['archive'];
  final String? openClawSha = argParseResult['openclaw_sha'];

  if (argParseResult['help']) {
    print(parser.usage);
    return;
  }

  if (argParseResult['openclaw_path'] == null ||
      (argParseResult['openclaw_path'] as String).isEmpty) {
    print("please provide [openclaw_path] option");
    print(parser.usage);
    return;
    // throw Exception("please provide [openclaw_path] option");
  } else {
    openClawPath = argParseResult['openclaw_path'];
  }

  String outputPath;

  if (argParseResult['output'] == null ||
      (argParseResult['output'] as String).isEmpty) {
    outputPath = '.';
    print("Using current directory as output folder");
  } else {
    outputPath = argParseResult['output'];
  }

  final directory = Directory(outputPath);
  if (!directory.existsSync()) {
    directory.createSync();
    print("Output folder not exist, creating");
  }

  String isarDBFileName;
  if (argParseResult['isar_name'] == null ||
      (argParseResult['isar_name'] as String).isEmpty) {
    isarDBFileName = 'default';
    print("using 'default' as Isar Database filename");
  } else {
    isarDBFileName = argParseResult['isar_name'];
  }

  await Isar.initializeIsarCore(download: true);
  final isar = await Isar.open(
    name: isarDBFileName,
    [
      DocEntrySchema,
      AppMetadataSchema,
      AppNavigationSchema,
      AppRedirectSchema,
      AppImageSchema,
    ],
    directory: outputPath,
    inspector: true,
  );

  isar.writeTxnSync(() {
    isar.docEntrys.clearSync();
    isar.appNavigations.clearSync();
    isar.appRedirects.clearSync();
    isar.appMetadatas.clearSync();
    isar.appImages.clearSync();
  });

  final imageDir = Directory(join(outputPath, 'images'));
  if (imageDir.existsSync()) {
    imageDir.deleteSync(recursive: true);
  }
  imageDir.createSync();

  await DocProcessor(
    docsRoot: join(openClawPath, 'docs'),
    isar: isar,
    imageDest: join(outputPath, 'images'),
  ).syncAll();

  await DocParser(isar: isar, openClawPath: openClawPath).updateDocs();

  final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  // Update a final "Bundle Version" metadata
  await isar.writeTxn(() async {
    await isar.appMetadatas.put(
      AppMetadata()
        ..key = MetadataKeys.bundleVersion
        ..valueInt = timestamp,
    );

    // ADD THIS: Store the SHA so the app knows its source
    if (openClawSha != null) {
      await isar.appMetadatas.put(
        AppMetadata()
          ..key = MetadataKeys.openClawSha
          ..valueString = openClawSha,
      );
    }
  });

  // At the very end of main()
  await isar.close();
  print("🚀 Isar database generated successfully at $outputPath");

  // Clean up the lock file so it doesn't get zipped
  final lockFile = File(join(outputPath, '$isarDBFileName.isar.lock'));
  if (lockFile.existsSync()) {
    lockFile.deleteSync();
    print("🗑️ Removed lock file.");
  }

  if (shouldArchive && openClawSha != null && openClawSha.isNotEmpty) {
    await archivePackageToDist(
      outputPath,
      isarDBFileName,
      openClawSha,
      timestamp,
    );
  }
}

Future archivePackageToDist(
  String outputPath,
  String isarDBFileName,
  String openClawSha,
  int timestamp,
) async {
  print("📦 Packaging assets...");

  final distDir = Directory('dist');
  if (distDir.existsSync()) {
    // Delete old builds to keep the dist clean
    distDir.deleteSync(recursive: true);
  }
  await distDir.create();

  // 2. Create the ZIP bundle
  final encoder = ZipFileEncoder();
  final zipPath = join('dist', '$timestamp.zip');
  encoder.create(zipPath);

  final isarFile = File(join(outputPath, '$isarDBFileName.isar'));
  if (isarFile.existsSync()) {
    await encoder.addFile(isarFile);
  } else {
    print("❌ Error: Could not find generated Isar file at ${isarFile.path}");
    exit(1);
  }

  final imageDir = Directory(join(outputPath, 'images'));
  if (imageDir.existsSync()) {
    await encoder.addDirectory(imageDir);
  } else {}
  await encoder.close();

  // 3. Calculate SHA-256
  final bytes = File('dist/$timestamp.zip').readAsBytesSync();
  final hash = sha256.convert(bytes).toString();

  // 4. Generate build.json
  final manifest = {
    MetadataKeys.bundleVersion: timestamp,
    MetadataKeys.jsonIsarHash: hash,
    MetadataKeys.openClawSha: openClawSha,
    MetadataKeys.jsonZipUrl: "$remoteDbBaseUrl/$timestamp.zip",
  };

  File('dist/build.json').writeAsStringSync(jsonEncode(manifest));
  print("✅ Build Complete: dist/build.json");
}
