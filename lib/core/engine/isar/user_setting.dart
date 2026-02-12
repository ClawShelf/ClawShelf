import 'package:isar/isar.dart';

part 'user_setting.g.dart';

@collection
class UserSetting {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  String? stringValue;
  int? intValue;
  bool? boolValue;

  @ignore
  // Helper to get the value regardless of type
  dynamic get value => stringValue ?? intValue ?? boolValue;
}

@collection
class HistoryEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String docId;

  late String title;
  late String emoji;

  late DateTime lastViewed;
}
