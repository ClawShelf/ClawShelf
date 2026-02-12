import 'package:claw_shelf/core/engine/isar/user_setting.dart';
import 'package:claw_shelf/core/engine/manager/document_manager.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:claw_shelf/components/recent_card.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/screens/category_list.dart';
import 'package:claw_shelf/screens/search.dart';
import 'package:claw_shelf/services/doc_navigation.dart';

class CSMainScreen extends StatefulWidget {
  const CSMainScreen({super.key});

  @override
  State<CSMainScreen> createState() => _CSMainScreenState();
}

class _CSMainScreenState extends State<CSMainScreen> {
  AppNavigation? _config;
  late Isar docsIsar;
  late Isar prefsIsar;

  @override
  void initState() {
    super.initState();
    docsIsar = GetIt.instance(instanceName: docsIsarKey);
    prefsIsar = GetIt.instance(instanceName: preferenceIsarKey);
    _loadConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SettingsRepository.runStartupSanitySweep();
    });
  }

  // Load the navigation tree from Isar
  Future<void> _loadConfig() async {
    final config = await docsIsar.appNavigations.where().findFirst();
    setState(() => _config = config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Sidebar now handles the "crowded" 2,400 doc hierarchy
      drawer: _config != null ? _buildNavigationDrawer(_config!) : null,

      body: CustomScrollView(
        slivers: [
          // 1. Adaptive Header with Search
          SliverAppBar(
            expandedHeight: 140.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Colors.deepPurple.shade900,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: _buildSmartSearchBar(),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),

          // 2. Bento Grid: High-Level Categories
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildBentoCard("Fundamentals", Icons.book, Colors.amber, [
                  'concepts',
                  'nodes',
                  'automation',
                ], isTall: true),
                _buildBentoCard("Quick Start", Icons.bolt, Colors.green, [
                  'start',
                  'help',
                  'reference',
                ]),
                _buildBentoCard(
                  "Skills & Tools",
                  Icons.extension,
                  Colors.redAccent,
                  ['tools', 'plugins', 'web'],
                ),
                _buildBentoCard("System & Setup", Icons.tune, Colors.blueGrey, [
                  'install',
                  'gateway',
                  'platforms',
                  'cli',
                ]),
              ]),
            ),
          ),

          _biuldRecentlyViewed(),
        ],
      ),
    );
  }

  Widget _buildSmartSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CSSearchScreen(lang: 'en')),
        );
      },
      child: Hero(
        tag: 'search_bar_hero', // Same tag must be used in SearchScreen
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Search agent commands...",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // RECURSIVE DRAWER Logic
  Widget _buildNavigationDrawer(AppNavigation config) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple.shade50),
            child: const Center(
              child: Text(
                "DOC INDEX",
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: config.tabs.map((tab) => _buildTabFolder(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Recursive widget to handle deep nesting
  Widget _buildTabFolder(NavTab tab) {
    return ExpansionTile(
      leading: const Icon(Icons.folder_open, size: 20),
      title: Text(tab.title ?? "Untitled"),
      children: tab.groups?.map((group) => _buildGroup(group)).toList() ?? [],
    );
  }

  Widget _buildGroup(NavGroup group) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: ExpansionTile(
        title: Text(group.title ?? "", style: const TextStyle(fontSize: 14)),
        children: group.nodes?.map((node) => _buildNode(node)).toList() ?? [],
      ),
    );
  }

  Widget _buildNode(NavNode node) {
    if (node.children != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: ExpansionTile(
          title: Text(node.title ?? "", style: const TextStyle(fontSize: 14)),
          children:
              node.children
                  ?.map(
                    (node) => ListTile(
                      dense: true,
                      title: Text(
                        node.title ??
                            CSDocNavigation.findDocByPath(node.path!)?.title ??
                            "Page",
                      ),
                      onTap: () {
                        // Navigate to content with the path (docId)
                        Navigator.pop(context); // Close drawer
                        _openDoc(node.path);
                      },
                    ),
                  )
                  .toList() ??
              [],
        ),
      );
    } else {
      return ListTile(
        dense: true,
        title: Text(
          node.title ??
              CSDocNavigation.findDocByPath(node.path!)?.title ??
              "Page",
        ),
        onTap: () {
          // Navigate to content with the path (docId)
          Navigator.pop(context); // Close drawer
          _openDoc(node.path);
        },
      );
    }
  }

  void _openDoc(String? path) async {
    if (path == null) return;
    CSDocNavigation.navigateToDoc(context, path);
  }

  Widget _buildBentoCard(
    String title,
    IconData icon,
    Color color,
    List<String> categories, {
    bool isTall = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CSCategoryListPage(
                  title: title,
                  categories:
                      categories, // Maps to your Python 'category' logic
                  lang: 'en', // 'en' or 'zh'
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _biuldRecentlyViewed() {
    return StreamBuilder<List<HistoryEntry>>(
      // Watch the DB: Sort by lastAccessed, limit to 5 most recent
      stream: prefsIsar.historyEntrys
          .where()
          .sortByLastViewedDesc()
          .limit(5)
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        final docs = snapshot.data ?? [];

        if (docs.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  "Recently Viewed",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final historyEntry = docs[index];
                    return RecentDocCard(
                      emoji: historyEntry.emoji,
                      title: historyEntry.title,
                      summary: historyEntry.summary,
                      onTap: () async {
                        final doc = docsIsar.docEntrys
                            .filter()
                            .docIdEqualTo(historyEntry.docId)
                            .findFirstSync();

                        if (doc == null) {
                          // Since this was missing, we delete all the history referencing this ID

                          await prefsIsar.writeTxn(() async {
                            // Delete EVERYTHING for this ID in one single disk trip
                            await prefsIsar.historyEntrys
                                .filter()
                                .docIdEqualTo(historyEntry.docId)
                                .deleteAll();
                          });

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Document no longer exists."),
                              ),
                            );
                          }
                        } else {
                          CSDocNavigation.open(context, doc);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
