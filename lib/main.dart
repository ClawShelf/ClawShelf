import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/user_setting.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:claw_shelf/services/isar_open.dart';
import 'package:flutter/material.dart';
import 'package:claw_shelf/screens/doc_seed.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

Future injectUserPref() async {
  final getIt = GetIt.instance;

  GetIt.I.registerSingleton(snackbarKey);

  // Open User Preferences immediately
  final dir = await getApplicationSupportDirectory();
  final prefsIsar = await openIsarSafe(
    schemas: [UserSettingSchema, HistoryEntrySchema],
    name: 'user_prefs',
    directory: dir.path,
    inspector: !MetadataKeys.inspectDocsIsar,
  );

  getIt.registerSingleton<Isar>(
    prefsIsar,
    instanceName: MetadataKeys.preferenceIsarKey,
  );
  getIt.registerLazySingleton(
    () =>
        SettingsRepository(getIt(instanceName: MetadataKeys.preferenceIsarKey)),
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
    final repo = GetIt.I<SettingsRepository>();
    return StreamBuilder(
      stream: repo.watchSetting(MetadataKeys.isDarkMode),
      builder: (context, snapshot) {
        // Using your isDarkMode() logic for the initial/current state
        UserSetting? isDarkRecord = repo.get(MetadataKeys.isDarkMode);
        isDarkRecord ??= UserSetting(id: -1)..boolValue = false;

        return MaterialApp(
          scaffoldMessengerKey: snackbarKey, // Register the key here
          title: 'ClawShelf',
          debugShowCheckedModeBanner: false,
          themeMode: isDarkRecord.boolValue == true
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            colorScheme: .fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          home: CSDocSeedScreen(),
        );
      },
    );
  }
}
