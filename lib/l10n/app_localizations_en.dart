// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get seedStartingUp => 'Starting up...';

  @override
  String get seedSeedingDocumentLibrary => 'Seeding document library...';

  @override
  String get seedApplyLatestUpdate => 'Applying latest updates...';

  @override
  String get seedLoadingDocuments => 'Loading documents...';

  @override
  String get bentoSearchHint => 'Search agent commands...';

  @override
  String get bentoFundamentals => 'Fundamentals';

  @override
  String get bentoQuickStart => 'Quick Start';

  @override
  String get bentoSkillsTools => 'Skills & Tools';

  @override
  String get bentoSystemSetup => 'System & Setup';

  @override
  String get bentoFullDocumentIndex => 'Full Document Index';

  @override
  String get bentoExploreHierarchy => 'Explore the complete library hierarchy';

  @override
  String get bentoRecentlyViewed => 'Recently Viewed';

  @override
  String get bentoDocumentNoLongerExist => 'Document no longer exists.';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get docDocumentation => 'Documentation';

  @override
  String get docIndexLibraryIndex => 'Library Index';

  @override
  String get docIndexGeneral => 'General';

  @override
  String get docIndexSection => 'Section';

  @override
  String get docIndexUntitledPage => 'Untitled Page';

  @override
  String get searchNoDocumentsFound => 'No documents found.';

  @override
  String get searchSearchHint => 'Search docs...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDisplay => 'Display';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeHint => 'Reduce eye strain in low light';

  @override
  String get settingsContentLocalization => 'Content & Localization';

  @override
  String get settingsContentLocalizationAppLanguage => 'App Language';

  @override
  String get settingsLinks => 'Links';

  @override
  String get settingsGithubRepository => 'GitHub Repository';

  @override
  String get settingsGithubHint => 'View source and report issues';

  @override
  String get settingsMaintenance => 'Maintenance';

  @override
  String get settingsClearHistory => 'Clear History';

  @override
  String get settingsClearHistoryHint =>
      'Removes your recently viewed documents';

  @override
  String get settingsViewLicenses => 'View Licenses';

  @override
  String get settingsClearHistoryDialogTitle => 'Clear History?';

  @override
  String get settingsClearHistoryDialogText =>
      'This will remove all entries from your \'Recent Docs\' list.';

  @override
  String get settingsClearHistoryDialogCancel => 'Cancel';

  @override
  String get settingsClearHistoryDialogClear => 'Clear';

  @override
  String get settingsClearHistorySnackBarMessage => 'Recent history cleared.';

  @override
  String get settingsLanguageDialogTitle => 'Select Language';

  @override
  String get documentManagerUpdateDownloadedSnackBarMessage =>
      '🚀 Updates downloaded. Applied on next restart.';
}
