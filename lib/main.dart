import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/user_setting.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:claw_shelf/l10n/app_localizations.dart';
import 'package:claw_shelf/services/isar_open.dart';
import 'package:flutter/material.dart';
import 'package:claw_shelf/screens/doc_seed.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  final settingsRepo = SettingsRepository(prefsIsar);
  settingsRepo.seedDefaultSettings();

  getIt.registerSingleton<Isar>(
    prefsIsar,
    instanceName: MetadataKeys.preferenceIsarKey,
  );
  getIt.registerLazySingleton(() => settingsRepo);
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
      stream: repo.watchAllSettings(),
      builder: (context, snapshot) {
        // Using your isDarkMode() logic for the initial/current state
        final isDarkRecord = repo.getIsDarkMode();
        final langCode = repo.getLanguage();

        late Locale appLocale;
        switch (langCode.stringValue) {
          case 'zh-Hans':
            appLocale = Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hans',
            );
            break;
          default:
            appLocale = Locale(langCode.stringValue!);
            break;
        }

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

          locale: appLocale,
          supportedLocales: const [
            Locale('en'),
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            // Add your localization delegates here (GlobalMaterialLocalizations, etc.)
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: CSDocSeedScreen(),
        );
      },
    );
  }
}
