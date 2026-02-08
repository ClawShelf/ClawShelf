import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:molt_manual/components/recent_card.dart';
import 'package:molt_manual/core/engine/isar/app_config.dart';
import 'package:molt_manual/core/engine/isar/document.dart';
import 'package:molt_manual/screens/category_list.dart';
import 'package:molt_manual/screens/search.dart';
import 'package:molt_manual/services/doc_navigation.dart';

class MoltManualMainPage extends StatefulWidget {
  final Isar isar;
  const MoltManualMainPage({super.key, required this.isar});

  @override
  State<MoltManualMainPage> createState() => _MoltManualMainPageState();
}

class _MoltManualMainPageState extends State<MoltManualMainPage> {
  AppNavigation? _config;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  // Load the navigation tree from Isar
  Future<void> _loadConfig() async {
    final config = await widget.isar.appNavigations.where().findFirst();
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
          MaterialPageRoute(
            builder: (context) => MMSearchPage(isar: widget.isar, lang: 'en'),
          ),
        );
      },
      child: Hero(
        tag: 'search_bar_hero', // Same tag must be used in SearchScreen
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              Text(
                "Search agent commands...",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
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
                            widget.isar.docEntrys
                                .filter()
                                .docIdEqualTo(node.targetId)
                                .findFirstSync()
                                ?.title ??
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
              widget.isar.docEntrys
                  .filter()
                  .docIdEqualTo(node.targetId)
                  .findFirstSync()
                  ?.title ??
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
    final doc = await widget.isar.docEntrys
        .filter()
        .docIdEqualTo(path.replaceAll('/', '_'))
        .findFirst();
    if (doc != null && mounted) {
      MMDocNavigation.open(context, widget.isar, doc);
    }
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
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
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
                builder: (context) => MMCategoryListPage(
                  isar: widget.isar,
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
                  color: color.withOpacity(0.1),
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
    return // Replace your SliverToBoxAdapter with this Stream-based version
    StreamBuilder<List<DocEntry>>(
      // Watch the DB: Sort by lastAccessed, limit to 5 most recent
      stream: widget.isar.docEntrys
          .filter()
          .lastAccessedIsNotNull()
          .sortByLastAccessedDesc() // Only show docs that have actually been opened
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
                    final doc = docs[index];
                    return RecentDocCard(
                      doc: doc,
                      onTap: () =>
                          MMDocNavigation.open(context, widget.isar, doc),
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
