import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/core/engine/isar/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

class SettingsRepository {
  final Isar _prefsIsar;

  SettingsRepository(this._prefsIsar);

  // Example: Dark Mode
  bool isDarkMode() {
    final setting = _prefsIsar.userSettings
        .filter()
        .keyEqualTo('dark_mode')
        .findFirstSync();
    return setting?.value == 'true';
  }

  Future<void> setDarkMode(bool value) async {
    await _prefsIsar.writeTxn(() async {
      await _prefsIsar.userSettings.put(
        UserSetting()
          ..key = 'dark_mode'
          ..boolValue = value,
      );
    });
  }

  /// Adds a document to the history or updates its timestamp if it exists
  Future<void> addToHistory(DocEntry doc) async {
    await _prefsIsar.writeTxn(() async {
      // 1. Put the new/updated entry
      await _prefsIsar.historyEntrys.put(
        HistoryEntry()
          ..docId = doc.docId!
          ..title = doc.title
          ..emoji = doc.emoji
          ..summary = doc.summary
          ..lastViewed = DateTime.now(),
      );

      // 2. Maintain only the last 5 entries
      final allHistory = await _prefsIsar.historyEntrys
          .where()
          .sortByLastViewedDesc()
          .findAll();

      if (allHistory.length > 5) {
        final idsToDelete = allHistory.sublist(5).map((e) => e.id).toList();
        await _prefsIsar.historyEntrys.deleteAll(idsToDelete);
      }
    });
  }

  /// Fetches the 5 most recent docs for the Home Screen
  List<HistoryEntry> getRecentDocs() {
    return _prefsIsar.historyEntrys
        .where()
        .sortByLastViewedDesc()
        .limit(5)
        .findAllSync();
  }

  // Inside your DocSeed screen or your main bootstrap logic
  static Future<void> runStartupSanitySweep() async {
    final prefsIsar = GetIt.instance<Isar>(
      instanceName: MetadataKeys.preferenceIsarKey,
    );
    final docsIsar = GetIt.instance<Isar>(
      instanceName: MetadataKeys.docsIsarKey,
    );

    // 1. Get all docIds currently in history
    final historyEntries = await prefsIsar.historyEntrys.where().findAll();
    if (historyEntries.isEmpty) return;

    // 2. Efficiently find which ones are missing from the Doc DB
    final List<Id> staleIds = [];

    for (final entry in historyEntries) {
      final exists =
          docsIsar.docEntrys
              .filter()
              .docIdEqualTo(entry.docId)
              .findFirstSync() !=
          null;

      if (!exists) {
        staleIds.add(entry.id);
      }
    }

    // 3. Batch delete all orphans in one trip
    if (staleIds.isNotEmpty) {
      await prefsIsar.writeTxn(() async {
        await prefsIsar.historyEntrys.deleteAll(staleIds);
      });
      debugPrint(
        "🧹 Startup Sweep: Removed ${staleIds.length} orphan history entries.",
      );
    }
  }
}
