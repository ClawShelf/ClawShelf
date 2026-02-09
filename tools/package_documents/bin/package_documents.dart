import 'package:claw_shelf/core/engine/isar/app_config.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:isar/isar.dart';

void main(List<String> arguments) async {
  await Isar.initializeIsarCore(download: true);
  final isar = await Isar.open(
    [DocEntrySchema, AppMetadataSchema, AppNavigationSchema, AppRedirectSchema],
    directory: './assets',
    inspector: false,
  );
  print("Working!");
}
