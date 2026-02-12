import 'package:isar/isar.dart';
part 'document.g.dart';

@collection
class DocEntry {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true, replace: true)
  String? docId; // e.g., "start_install"

  String? docPath;

  // Filter by category for Bento Boxes (e.g., 'concepts', 'cli')
  @Index(type: IndexType.value)
  String category = "general";

  // Filter by language (e.g., 'en', 'zh')
  @Index(type: IndexType.value)
  String lang = "en";

  String? title;
  String? emoji;

  // Isar's Full-Text Search index
  @Index(type: IndexType.hash)
  String content = "";

  // For the "Recently Viewed" section on the Main Page
  @Index(type: IndexType.value)
  DateTime? lastAccessed;

  String? summary;

  // Isar handles List<String> natively
  List<String>? readWhen;

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

@collection
class AppImage {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String filename; // e.g., "logo_dark.png"

  @Index()
  late String localPath; // Absolute path to the file in app docs

  late String originalSource; // The original relative path from docs.json

  // Link to the DocEntry it belongs to (Optional but helpful)
  final docEntries = IsarLinks<DocEntry>();

  // Metadata for the UI
  int? width;
  int? height;
  String? mimeType;

  @Index()
  DateTime? lastSynced;
}
