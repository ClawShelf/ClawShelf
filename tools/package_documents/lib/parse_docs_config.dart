import 'dart:convert';
import 'dart:io';
import 'package:claw_shelf/core/engine/isar/app_config.dart';
import 'package:isar/isar.dart';

class DocParser {
  final Isar isar;
  final String openClawPath;

  DocParser({required this.isar, required this.openClawPath});

  Future<void> updateDocs() async {
    final String docsJsonPath = '$openClawPath/docs/docs.json';
    final file = File(docsJsonPath);

    if (!await file.exists()) {
      throw Exception("docs.json not found at $docsJsonPath");
    }

    final Map<String, dynamic> data = jsonDecode(await file.readAsString());

    // --- BUILD-TIME REDIRECT RESOLUTION ---
    // Create a local map for instant lookup during parsing
    final Map<String, String> redirectMap = {};
    final List<dynamic> redirectsData = data['redirects'] ?? [];
    final List<AppRedirect> redirectList = [];

    for (var r in redirectsData) {
      if (r is Map && r.containsKey('source') && r.containsKey('destination')) {
        redirectMap[r['source']] = r['destination'];
        // We still store them in the list if you want to keep the AppRedirect collection
        redirectList.add(
          AppRedirect()
            ..source = r['source']
            ..destination = r['destination'],
        );
      }
    }

    // 1. Recursive Node Processor with Resolution logic
    List<NavNode> processNodes(List<dynamic> pagesList) {
      return pagesList.map((item) {
        if (item is String) {
          // Normalize path to match redirect keys (usually starts with /)
          final String normalizedPath = item.startsWith('/') ? item : '/$item';

          // Resolve: if redirectMap has the path, use destination, else use original
          final String finalPath = redirectMap[normalizedPath] ?? item;

          return NavNode()
            ..type = "page"
            ..path = finalPath;
        } else {
          return NavNode()
            ..type = "group"
            ..title = item['group']
            ..children = processNodes(item['pages'] ?? []);
        }
      }).toList();
    }

    // 2. Prepare Navigation Collections
    final List<AppNavigation> navList = [];
    final List<dynamic> languages = data['navigation']?['languages'] ?? [];

    for (var lang in languages) {
      final appNav = AppNavigation()
        ..languageCode = lang['language']
        ..tabs = [];

      for (var tab in (lang['tabs'] ?? [])) {
        final navTab = NavTab()
          ..title = tab['tab']
          ..groups = [];

        for (var group in (tab['groups'] ?? [])) {
          navTab.groups!.add(
            NavGroup()
              ..title = group['group']
              ..nodes = processNodes(group['pages'] ?? []),
          );
        }
        appNav.tabs.add(navTab);
      }
      navList.add(appNav);
    }

    // 3. Atomic Write to Isar
    await isar.writeTxn(() async {
      // Clear old data
      await isar.appNavigations.clear();
      await isar.appRedirects.clear();

      // Batch insert resolved data
      await isar.appNavigations.putAll(navList);
      await isar.appRedirects.putAll(redirectList);
    });

    print(
      "✅ Build-time resolution complete: ${navList.length} languages processed.",
    );
    print("🔗 ${redirectList.length} redirects mapped into navigation tree.");
  }
}
