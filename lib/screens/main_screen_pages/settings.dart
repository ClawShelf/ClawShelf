import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/user_setting.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
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
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        children: [
          _buildHeader("Display"),

          // Dark Mode Toggle using your Repo logic
          StreamBuilder(
            // We watch the collection to react to changes
            stream: _repo.watchSetting(MetadataKeys.isDarkMode),
            builder: (context, snapshot) {
              // Using your isDarkMode() logic for the initial/current state
              final isDarkRecord = _repo.getIsDarkMode();

              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text("Dark Mode"),
                subtitle: const Text("Reduce eye strain in low light"),
                value: isDarkRecord.boolValue!,
                onChanged: (bool value) {
                  isDarkRecord.boolValue = value;
                  _repo.saveSettings(isDarkRecord);
                },
              );
            },
          ),

          const Divider(),
          _buildHeader("Content & Localization"),

          StreamBuilder(
            stream: _repo.watchSetting(MetadataKeys.language),
            builder: (context, snapshot) {
              final langaugeRecord = _repo.getLanguage();

              return ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text("App Language"),
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
            title: const Text("GitHub Repository"),
            subtitle: const Text("View source and report issues"),
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () => _launchGitHub(),
          ),

          const Divider(),
          _buildHeader("Maintenance"),

          ListTile(
            leading: const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.orange,
            ),
            title: const Text("Clear History"),
            subtitle: const Text("Removes your recently viewed documents"),
            onTap: () => _confirmClearHistory(context),
          ),

          const AboutListTile(
            icon: Icon(Icons.info_outline_rounded),
            applicationName: 'ClawShelf',
            applicationVersion: '1.1.0',
            applicationLegalese: '© 2026 ClawShelf Contributors',
            child: Text("View Licenses"),
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
        title: const Text("Clear History?"),
        content: const Text(
          "This will remove all entries from your 'Recent Docs' list.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // You can add a clearHistory() method to your Repository
              _repo.clearRecentlyViewed();
              GetIt.instance<GlobalKey<ScaffoldMessengerState>>().currentState
                  ?.showSnackBar(
                    const SnackBar(content: Text("Recent history cleared.")),
                  );
              Navigator.pop(context);
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
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
        title: const Text("Select Language"),
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
