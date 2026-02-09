import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:claw_shelf/core/engine/isar/app_config.dart';

Future<void> loadConfigIntoIsar(Isar isar) async {
  // 1. Load the file from assets
  final String response = await rootBundle.loadString('assets/app_config.json');
  final data = json.decode(response);

  final navigationMap = data['navigation'] as Map<String, dynamic>;

  List<AppNavigation> allNavs = [];

  // 2. Map JSON to Isar Collections
  navigationMap.forEach((langCode, tabsList) {
    final nav = AppNavigation()
      ..languageCode = langCode
      ..tabs = (tabsList as List)
          .map(
            (t) => NavTab()
              ..title = t['tab_title']
              ..groups = (t['groups'] as List)
                  .map(
                    (g) => NavGroup()
                      ..title = g['group_title']
                      ..nodes = _parseNodes(g['pages']),
                  )
                  .toList(),
          )
          .toList();

    allNavs.add(nav);
  });

  // 3. Save to Isar
  await isar.writeTxn(() async {
    await isar.appNavigations.putAll(allNavs);
  });
}

List<NavNode> _parseNodes(List<dynamic> nodes) {
  return nodes
      .map(
        (n) => NavNode()
          ..type = n['type']
          ..path = n['path']
          ..title = n['title']
          ..children = n['children'] != null
              ? _parseNodes(n['children'])
              : null,
      )
      .toList();
}
