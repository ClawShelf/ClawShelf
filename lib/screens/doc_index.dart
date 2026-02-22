import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/l10n/app_localizations.dart';
import 'package:claw_shelf/services/doc_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_plus/isar_plus.dart';

class CSDocIndexScreen extends StatefulWidget {
  final String lang;
  const CSDocIndexScreen({super.key, required this.lang});

  @override
  State<CSDocIndexScreen> createState() => _CSDocIndexScreenState();
}

class _CSDocIndexScreenState extends State<CSDocIndexScreen> {
  AppNavigation? _config;
  bool _isLoading = true;
  late Isar docsIsar;

  @override
  void initState() {
    super.initState();
    docsIsar = GetIt.instance(instanceName: MetadataKeys.docsIsarKey);
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    // Fetch navigation from Isar Plus
    final config = docsIsar.appNavigations
        .where()
        .languageCodeEqualTo(widget.lang)
        .findFirst();
    if (mounted) {
      setState(() {
        _config = config;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.docIndexLibraryIndex),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _config == null
          ? const Center(child: Text("No navigation data found."))
          : _buildNavigationTree(_config!),
    );
  }

  Widget _buildNavigationTree(AppNavigation config) {
    // Using a Scrollbar for better UX on long lists
    return Scrollbar(
      interactive: true,
      thickness: 6,
      radius: const Radius.circular(10),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 40), // Space at bottom
        itemCount: config.tabs.length,
        itemBuilder: (context, index) {
          final tab = config.tabs[index];
          return _buildTabFolder(tab);
        },
      ),
    );
  }

  // LEVEL 1: Tabs (Main Categories)
  Widget _buildTabFolder(NavTab tab) {
    return Theme(
      // Removes the default borders ExpansionTile adds
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(
          Icons.folder_copy_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          tab.title ?? AppLocalizations.of(context)!.docIndexGeneral,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        children: tab.groups?.map((group) => _buildGroup(group)).toList() ?? [],
      ),
    );
  }

  // LEVEL 2: Groups (Sub-folders)
  Widget _buildGroup(NavGroup group) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ExpansionTile(
        leading: const Icon(Icons.folder_open_outlined, size: 20),
        title: Text(
          group.title ?? "",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children:
            group.nodes?.map((node) => _buildRecursiveNode(node, 0)).toList() ??
            [],
      ),
    );
  }

  // LEVEL 3+: Recursive Nodes (Can be folders or files)
  Widget _buildRecursiveNode(NavNode node, int depth) {
    final bool isFolder = node.children != null && node.children!.isNotEmpty;
    final double leftPadding = 16.0 + (depth * 12.0);

    if (isFolder) {
      return Padding(
        padding: EdgeInsets.only(left: depth == 0 ? 8.0 : 0.0),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(left: leftPadding),
          leading: const Icon(Icons.subdirectory_arrow_right, size: 16),
          title: Text(
            node.title ?? AppLocalizations.of(context)!.docIndexSection,
            style: const TextStyle(fontSize: 15),
          ),
          children: node.children!
              .map((child) => _buildRecursiveNode(child, depth + 1))
              .toList(),
        ),
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.only(left: leftPadding + 32),
        dense: true,
        leading: const Icon(Icons.article_outlined, size: 18),
        title: Text(
          node.title ??
              CSDocNavigation.findDocByPath(node.path!)?.title ??
              AppLocalizations.of(context)!.docIndexUntitledPage,
          style: const TextStyle(fontSize: 14),
        ),
        onTap: () => _openDoc(node.path),
      );
    }
  }

  void _openDoc(String? path) {
    if (path == null) return;
    // NOTE: We don't Navigator.pop(context) here because this is a full page.
    // The user should be able to press "back" from the doc and return here.
    CSDocNavigation.navigateToDoc(context, path);
  }
}
