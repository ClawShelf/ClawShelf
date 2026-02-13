import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/args.dart';
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
    ..addFlag('verbose', abbr: 'v', help: 'Verbose output')
    ..addOption('openclaw_path', help: 'Path to openclaw repository')
    ..addOption('output', abbr: 'o', help: 'Output Isar database directory')
    ..addOption('isar_name', help: 'Isar database file name');

  ArgResults result;
  String openClawPath;
  try {
    result = parser.parse(arguments);
    if (result['openclaw_path'] == null ||
        (result['openclaw_path'] as String).isEmpty) {
      throw Exception("please provide [openclaw_path] option");
    } else {
      openClawPath = result['openclaw_path'];
    }
    // print(result['output'] as String?);
  } on ArgParserException catch (e) {
    print("Argument parsing error: ${e.message}");
    exit(1);
  } catch (e) {
    print(e);
    exit(1);
  }

  String outputPath;

  if (result['output'] == null || (result['output'] as String).isEmpty) {
    outputPath = '.';
    print("Using current directory as output folder");
  } else {
    outputPath = result['output'];
  }

  final directory = Directory(outputPath);
  if (!directory.existsSync()) {
    directory.createSync();
    print("Output folder not exist, creating");
  }

  String isarDBFileName;
  if (result['isar_name'] == null || (result['isar_name'] as String).isEmpty) {
    isarDBFileName = 'default';
    print("using 'default' as Isar Database filename");
  } else {
    isarDBFileName = result['isar_name'];
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
    inspector: false,
  );

  isar.writeTxnSync(() {
    isar.docEntrys.clearSync();
    isar.appNavigations.clearSync();
    isar.appRedirects.clearSync();
    isar.appMetadatas.clearSync();
    isar.appImages.clearSync();
  });

  await DocProcessor(
    docsRoot: join(openClawPath, 'docs'),
    isar: isar,
    imageDest: join(outputPath, 'images'),
  ).syncAll();

  await DocParser(isar: isar, openClawPath: openClawPath).updateDocs();

  // Update a final "Bundle Version" metadata
  await isar.writeTxn(() async {
    await isar.appMetadatas.put(
      AppMetadata()
        ..key = "bundle_build_date"
        ..value = DateTime.now().millisecondsSinceEpoch,
    );
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

  print("📦 Packaging assets...");

  final distDir = Directory('dist');
  if (!distDir.existsSync()) {
    distDir.createSync();
  }

  final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  // 2. Create the ZIP bundle
  final encoder = ZipFileEncoder();
  final zipPath = join('dist', 'bundle.zip');
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
  final bytes = File('dist/bundle.zip').readAsBytesSync();
  final hash = sha256.convert(bytes).toString();

  // 4. Generate build.json
  final manifest = {
    "version": timestamp,
    "isar_hash": hash,
    "zip_url": "https://your-server.com/builds/$timestamp.zip",
  };

  File('dist/build.json').writeAsStringSync(jsonEncode(manifest));
  print("✅ Build Complete: dist/build.json");
}
