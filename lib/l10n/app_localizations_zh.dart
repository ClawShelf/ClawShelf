// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get seedStartingUp => '启动中...';

  @override
  String get seedSeedingDocumentLibrary => '加载文档...';

  @override
  String get seedApplyLatestUpdate => '正在应用最新更新...';

  @override
  String get seedLoadingDocuments => '加载文档...';

  @override
  String get bentoSearchHint => '搜索命令...';

  @override
  String get bentoFundamentals => '基础知识';

  @override
  String get bentoQuickStart => '快速开始';

  @override
  String get bentoSkillsTools => '技能与工具';

  @override
  String get bentoSystemSetup => '系统设置';

  @override
  String get bentoFullDocumentIndex => '完整文档索引';

  @override
  String get bentoExploreHierarchy => '探索完整的库层级结构';

  @override
  String get bentoRecentlyViewed => '最近阅读';

  @override
  String get bentoDocumentNoLongerExist => '文档已删除.';

  @override
  String get navHome => '首页';

  @override
  String get navSettings => '设置';

  @override
  String get docDocumentation => '文档';

  @override
  String get docIndexLibraryIndex => '目录';

  @override
  String get docIndexGeneral => '通用';

  @override
  String get docIndexSection => '章节';

  @override
  String get docIndexUntitledPage => '无标题页面';

  @override
  String get searchNoDocumentsFound => '未找到文档。';

  @override
  String get searchSearchHint => '搜索文档...';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsDisplay => '显示';

  @override
  String get settingsDarkMode => '暗色模式';

  @override
  String get settingsDarkModeHint => '在暗光环境下减轻眼部疲劳';

  @override
  String get settingsContentLocalization => '内容与本地化';

  @override
  String get settingsContentLocalizationAppLanguage => '应用语言';

  @override
  String get settingsLinks => '链接';

  @override
  String get settingsGithubRepository => 'GitHub 仓库';

  @override
  String get settingsGithubHint => '查看源代码及反馈问题';

  @override
  String get settingsMaintenance => '维护';

  @override
  String get settingsClearHistory => '清除历史记录';

  @override
  String get settingsClearHistoryHint => '移除您最近查看的文档记录';

  @override
  String get settingsViewLicenses => '查看开源许可';

  @override
  String get settingsClearHistoryDialogTitle => '清除历史记录？';

  @override
  String get settingsClearHistoryDialogText => '这将从“最近查看”列表中移除所有条目。';

  @override
  String get settingsClearHistoryDialogCancel => '取消';

  @override
  String get settingsClearHistoryDialogClear => '清除';

  @override
  String get settingsClearHistorySnackBarMessage => '最近历史记录已清除。';

  @override
  String get settingsLanguageDialogTitle => '选择语言';

  @override
  String get documentManagerUpdateDownloadedSnackBarMessage =>
      '🚀 更新已下载。将在下次重启时应用。';
}
