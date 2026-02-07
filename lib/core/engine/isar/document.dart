import 'package:isar/isar.dart';
part 'document.g.dart';

@collection
class DocEntry {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? docId; // e.g., "start_install"

  @Index(type: IndexType.value)
  String category = "General";

  String? title;
  String? emoji;

  // Isar's Full-Text Search index
  @Index(type: IndexType.hash)
  String content = "";

  DateTime? lastUpdated;
}

@collection
class AppMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? key; // e.g., "synced_build" or "docs_hash"

  // We make these optional so a single record
  // doesn't have to provide both an int AND a string.
  int? value;
  String? valueString;
}
