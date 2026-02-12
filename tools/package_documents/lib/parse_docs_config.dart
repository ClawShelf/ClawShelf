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
    
    // 1. Recursive Node Processor (Handles nested groups)
    List<NavNode> processNodes(List<dynamic> pagesList) {
      return pagesList.map((item) {
        if (item is String) {
          return NavNode()
            ..type = "page"
            ..path = item;
        } else {
          return NavNode()
            ..type = "group"
            ..title = item['group']
            ..children = processNodes(item['pages'] ?? []);
        }
      }).toList();
    }

    // 2. Prepare Collections
    final List<AppNavigation> navList = [];
    final List<AppRedirect> redirectList = [];

    // Process Redirects
    final List<dynamic> redirectsData = data['redirects'] ?? [];
    for (var r in redirectsData) {
      if (r is Map && r.containsKey('source') && r.containsKey('destination')) {
        redirectList.add(AppRedirect()
          ..source = r['source']
          ..destination = r['destination']);
      }
    }

    // Process Languages & Navigation
    final List<dynamic> languages = data['navigation']?['languages'] ?? [];
    for (var lang in languages) {
      final appNav = AppNavigation()
        ..languageCode = lang['language']
        ..tabs = [];
      
      for (var tab in (lang['tabs'] ?? [])) {
        final navTab = NavTab()..title = tab['tab']..groups = [];
        
        for (var group in (tab['groups'] ?? [])) {
          navTab.groups!.add(NavGroup()
            ..title = group['group']
            ..nodes = processNodes(group['pages'] ?? []));
        }
        appNav.tabs.add(navTab);
      }
      navList.add(appNav);
    }

    // 3. Atomic Write to Isar
    await isar.writeTxn(() async {
      // Clear old navigation and redirects to prevent duplicates
      await isar.appNavigations.clear();
      await isar.appRedirects.clear();

      // Batch insert new data
      await isar.appNavigations.putAll(navList);
      await isar.appRedirects.putAll(redirectList);
    });
    
    print("Parsed ${navList.length} languages and ${redirectList.length} redirects.");
  }
}