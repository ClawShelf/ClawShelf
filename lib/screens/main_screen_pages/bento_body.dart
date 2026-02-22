import 'package:claw_shelf/components/recent_card.dart';
import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/core/engine/isar/user_setting.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:claw_shelf/screens/category_list.dart';
import 'package:claw_shelf/screens/doc_index.dart';
import 'package:claw_shelf/screens/search.dart';
import 'package:claw_shelf/services/doc_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_plus/isar_plus.dart';

class CSMainPageBentoBody extends StatefulWidget {
  const CSMainPageBentoBody({super.key});

  @override
  State<CSMainPageBentoBody> createState() => _CSMainPageBentoBodyState();
}

class _CSMainPageBentoBodyState extends State<CSMainPageBentoBody> {
  late Isar docsIsar;
  late Isar prefsIsar;
  late SettingsRepository settingsRepository;

  @override
  void initState() {
    super.initState();
    docsIsar = GetIt.instance(instanceName: MetadataKeys.docsIsarKey);
    prefsIsar = GetIt.instance(instanceName: MetadataKeys.preferenceIsarKey);
    settingsRepository = GetIt.instance();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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

        // 3. The "Big Button" to Doc Index
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CSDocIndexScreen(
                    lang: settingsRepository.getLanguage().stringValue!,
                  ),
                ),
              ),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_tree_rounded, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Full Document Index",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text("Explore the complete library hierarchy"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        _biuldRecentlyViewed(),
      ],
    );
  }

  Widget _buildSmartSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CSSearchScreen(
              lang: settingsRepository.getLanguage().stringValue!,
            ),
          ),
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

  Widget _buildBentoCard(
    String title,
    IconData icon,
    Color color,
    List<String> categories, {
    bool isTall = false,
  }) {
    // Access the current theme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        // Use surfaceContainer or surface for the card background
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05,
            ),
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
                  categories: categories,
                  lang: settingsRepository.getLanguage().stringValue!,
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
                  // Keep the icon background subtle
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  // Use onSurface to ensure text is black in light and white in dark
                  color: colorScheme.onSurface,
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
      stream: prefsIsar.historyEntrys.where().sortByLastViewedDesc().watch(
        fireImmediately: true,
        limit: 5,
      ),
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
                            .where()
                            .docIdEqualTo(historyEntry.docId)
                            .findFirst();

                        if (doc == null) {
                          // Since this was missing, we delete all the history referencing this ID

                          await prefsIsar.writeAsync((isar) async {
                            // Delete EVERYTHING for this ID in one single disk trip
                            isar.historyEntrys
                                .where()
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
