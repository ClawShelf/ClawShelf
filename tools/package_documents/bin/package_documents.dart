import 'dart:io';

import 'package:args/args.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:isar/isar.dart';
import 'package:package_documents/generate_bundle.dart';
import 'package:package_documents/parse_docs_config.dart';
import 'package:path/path.dart';

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
}
