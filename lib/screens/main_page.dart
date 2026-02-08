import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:molt_manual/core/engine/isar/app_config.dart';
import 'package:molt_manual/core/engine/isar/document.dart';
import 'package:molt_manual/screens/doc_content.dart';

class MoltManualMainPage extends StatefulWidget {
  const MoltManualMainPage({super.key, required this.isar});
  final Isar isar;

  @override
  State<MoltManualMainPage> createState() => _MoltManualMainPageState();
}

class _MoltManualMainPageState extends State<MoltManualMainPage> {
  int _currentIndex = 0;
  List<AppNavigation> _navConfigs = [];

  @override
  void initState() {
    super.initState();
    _loadNavigation();
  }

  // Fetch the navigation config (e.g., for the 'en' language)
  Future<void> _loadNavigation() async {
    final configs = await widget.isar.appNavigations
        .filter()
        .languageCodeEqualTo("en")
        .findAll();
    setState(() {
      _navConfigs = configs;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_navConfigs.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get the tabs from your embedded NavTab model
    final tabs = _navConfigs.first.tabs;

    return Scaffold(
      // 1. Dynamic Body using IndexedStack to keep tabs "alive"
      body: IndexedStack(
        index: _currentIndex,
        children: tabs.map((tab) => _buildTabContent(tab)).toList(),
      ),

      // 2. Dynamic Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.amber,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: const Icon(
              Icons.folder_open,
            ), // You could map this to your JSON icons
            label: tab.title ?? "Tab",
            backgroundColor: Colors.blue,
          );
        }).toList(),
      ),
    );
  }

  // This helper builds the actual view for each tab
  Widget _buildTabContent(NavTab tab) {
    // For now, let's show the groups/nodes defined in your config
    return CustomScrollView(
      slivers: [
        SliverAppBar(title: Text(tab.title ?? "Manual")),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final group = tab.groups?[index];
            return Card(
              child: ExpansionTile(
                title: Text(group?.title ?? "Group"),
                children:
                    group?.nodes?.map((node) => _buildTabItem(node)).toList() ??
                    [],
              ),
            );
          }, childCount: tab.groups?.length ?? 0),
        ),
      ],
    );
  }

  Widget _buildTabItem(NavNode node) {
    if (node.children != null) {
      return Card(
        child: ExpansionTile(
          title: Text(node.title ?? "Page"),
          subtitle: Text(node.path ?? ""),
          children: node.children!
              .map((child) => _buildTabItem(child))
              .toList(),
        ),
      );
    } else {
      return ListTile(
        title: Text(
          node.title ??
              widget.isar.docEntrys
                  .filter()
                  .docIdEqualTo(node.path?.replaceAll('/', '_'))
                  .findFirstSync()
                  ?.title ??
              "Page",
        ),
        subtitle: Text(node.path ?? ""),
        onTap: () async {
          // Logic to handle navigation to the 'path'
          final targetDoc = await widget.isar.docEntrys
              .filter()
              .docIdEqualTo(node.path?.replaceAll('/', '_'))
              .findFirst();
          if (targetDoc != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DocContentPage(id: targetDoc.id, isar: widget.isar),
              ),
            );
          }
        },
      );
    }
  }
}
