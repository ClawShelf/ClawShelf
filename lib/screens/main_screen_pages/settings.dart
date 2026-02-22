import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/user_setting.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:claw_shelf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

class CSSettingsPage extends StatefulWidget {
  const CSSettingsPage({super.key});

  @override
  State<CSSettingsPage> createState() => _CSSettingsPageState();
}

class _CSSettingsPageState extends State<CSSettingsPage> {
  // Accessing the repository via GetIt
  final _repo = GetIt.I<SettingsRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildHeader(AppLocalizations.of(context)!.settingsDisplay),

          // Dark Mode Toggle using your Repo logic
          StreamBuilder(
            // We watch the collection to react to changes
            stream: _repo.watchSetting(MetadataKeys.isDarkMode),
            builder: (context, snapshot) {
              // Using your isDarkMode() logic for the initial/current state
              final isDarkRecord = _repo.getIsDarkMode();

              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(AppLocalizations.of(context)!.settingsDarkMode),
                subtitle: Text(
                  AppLocalizations.of(context)!.settingsDarkModeHint,
                ),
                value: isDarkRecord.boolValue!,
                onChanged: (bool value) {
                  isDarkRecord.boolValue = value;
                  _repo.saveSettings(isDarkRecord);
                },
              );
            },
          ),

          const Divider(),
          _buildHeader(
            AppLocalizations.of(context)!.settingsContentLocalization,
          ),

          StreamBuilder(
            stream: _repo.watchSetting(MetadataKeys.language),
            builder: (context, snapshot) {
              final langaugeRecord = _repo.getLanguage();

              return ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(
                  AppLocalizations.of(
                    context,
                  )!.settingsContentLocalizationAppLanguage,
                ),
                subtitle: Text(
                  langaugeRecord.stringValue == 'en' ? "English" : '中文',
                ), // You can expand this later
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, langaugeRecord),
              );
            },
          ),

          const Divider(),
          _buildHeader("Links"),

          ListTile(
            leading: const Icon(Icons.code_rounded),
            title: Text(AppLocalizations.of(context)!.settingsGithubRepository),
            subtitle: Text(AppLocalizations.of(context)!.settingsGithubHint),
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () => _launchGitHub(),
          ),

          const Divider(),
          _buildHeader(AppLocalizations.of(context)!.settingsMaintenance),

          ListTile(
            leading: const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.orange,
            ),
            title: Text(AppLocalizations.of(context)!.settingsClearHistory),
            subtitle: Text(
              AppLocalizations.of(context)!.settingsClearHistoryHint,
            ),
            onTap: () => _confirmClearHistory(context),
          ),

          AboutListTile(
            icon: Icon(Icons.info_outline_rounded),
            applicationName: 'ClawShelf',
            applicationVersion: '1.1.0',
            applicationLegalese: '© 2026 ClawShelf Contributors',
            child: Text(AppLocalizations.of(context)!.settingsViewLicenses),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _launchGitHub() async {
    final url = Uri.parse('https://github.com/ClawShelf/ClawShelf');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.settingsClearHistoryDialogTitle,
        ),
        content: Text(
          AppLocalizations.of(context)!.settingsClearHistoryDialogText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.settingsClearHistoryDialogCancel,
            ),
          ),
          TextButton(
            onPressed: () {
              // You can add a clearHistory() method to your Repository
              _repo.clearRecentlyViewed();
              GetIt.instance<GlobalKey<ScaffoldMessengerState>>().currentState
                  ?.showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.settingsClearHistorySnackBarMessage,
                      ),
                    ),
                  );
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.settingsClearHistoryDialogClear,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    UserSetting currentLanguageRecord,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.settingsLanguageDialogTitle),
        children: [
          _langOption(
            context,
            "English",
            MetadataKeys.languageEN,
            currentLanguageRecord,
          ),
          _langOption(
            context,
            "中文",
            MetadataKeys.languageZHHans,
            currentLanguageRecord,
          ),
        ],
      ),
    );
  }

  Widget _langOption(
    BuildContext context,
    String label,
    String code,
    UserSetting currentLanguageRecord,
  ) {
    return SimpleDialogOption(
      onPressed: () {
        currentLanguageRecord.stringValue = code;
        _repo.saveSettings(currentLanguageRecord);
        Navigator.pop(context);
      },
      child: ListTile(
        leading: currentLanguageRecord.stringValue == code
            ? Icon(Icons.check)
            : Icon(Icons.check_box_outline_blank),
        title: Text(label),
      ),
    );
  }
}
