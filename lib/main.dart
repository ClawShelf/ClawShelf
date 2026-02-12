import 'package:claw_shelf/core/engine/isar/user_setting.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:claw_shelf/screens/doc_seed.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

Future injectUserPref() async {
  final getIt = GetIt.instance;

  // Open User Preferences immediately
  final dir = await getApplicationSupportDirectory();
  final prefsIsar = await Isar.open(
    [UserSettingSchema, HistoryEntrySchema],
    name: 'user_prefs',
    directory: dir.path,
  );

  getIt.registerSingleton<Isar>(prefsIsar, instanceName: preferenceIsarKey);
  getIt.registerLazySingleton(
    () => SettingsRepository(getIt(instanceName: preferenceIsarKey)),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await injectUserPref();

  runApp(const ClawShelfApp());
}

class ClawShelfApp extends StatelessWidget {
  const ClawShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClawShelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: CSDocSeedScreen(),
    );
  }
}
