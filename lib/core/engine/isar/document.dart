import 'package:isar_plus/isar_plus.dart';

part 'document.g.dart';

@collection
class DocEntry {
  DocEntry({required this.id});

  final int id;

  @Index(unique: true)
  String? docId; // e.g., "start_install"

  String? docPath;

  // Filter by category for Bento Boxes (e.g., 'concepts', 'cli')
  @Index()
  String category = "general";

  // Filter by language (e.g., 'en', 'zh')
  @Index()
  String lang = "en";

  String? title;
  String? emoji;

  // Isar's Full-Text Search index
  @Index()
  String content = "";

  String? summary;

  // Isar handles List<String> natively
  List<String>? readWhen;

  DateTime? lastUpdated;
}

@collection
class AppMetadata {
  AppMetadata({required this.id});

  final int id;

  @Index(unique: true)
  String? key; // e.g., "synced_build" or "docs_hash"

  // We make these optional so a single record
  // doesn't have to provide both an int AND a string.
  int? valueInt;
  String? valueString;
  bool? valueBool;

  /// A helper to get whatever value is present.
  /// @ignore ensures Isar doesn't try to persist a 'dynamic' type.
  @ignore
  dynamic get value => valueString ?? valueInt ?? valueBool;
}

@collection
class AppImage {
  AppImage({required this.id});

  final int id;

  @Index(unique: true)
  String? filename; // e.g., "logo_dark.png"

  @Index()
  String? localPath; // Absolute path to the file in app docs

  String? originalSource; // The original relative path from docs.json

  // Link to the DocEntry it belongs to (Optional but helpful)
  List<String>? docEntryIds;

  // Metadata for the UI
  int? width;
  int? height;
  String? mimeType;

  @Index()
  DateTime? lastSynced;
}

@collection
class AppNavigation {
  AppNavigation({required this.id});

  final int id;

  @Index(unique: true)
  String languageCode = "en"; // "en" or "zh-Hans"

  List<NavTab> tabs = [];
}

@embedded
class NavTab {
  String? title;
  List<NavGroup>? groups;
}

@embedded
class NavGroup {
  String? title;
  List<NavNode>? nodes;
}

@embedded
class NavNode {
  String? type; // "page" or "group"
  String? title; // Only if type is "group"
  String? path; // Only if type is "page"
  List<NavNode>? children; // Recursive for nested groups

  @ignore
  String? get targetId => path?.replaceAll("/", "_");

  // Future<DocEntry?> fetchDoc(Isar isar) async {
  //   if (path == null || path!.isEmpty) return null;

  //   // 1. Normalize the input path to match your JSON redirect format
  //   // If your NavNode path is "model_failover", but JSON is "/model-failover"
  //   String lookupPath = path!.startsWith('/')
  //       ? path!
  //       : '/${path!.replaceAll('_', '/')}';

  //   // 2. Query the Redirect table
  //   final redirect = isar.appRedirects
  //       .where()
  //       .sourceEqualTo(lookupPath)
  //       .findFirst();

  //   // 3. Determine the final destination
  //   String finalPath = redirect != null ? redirect.destination! : lookupPath;

  //   // 4. Convert the destination back to the Isar DocID format
  //   // Example: "/concepts/model-failover" -> "concepts_model-failover"
  //   String sanitizedDocId = finalPath
  //       .replaceFirst('/', '') // Remove leading slash
  //       .replaceAll('/', '_'); // Slashes to underscores

  //   return isar.docEntrys.where().docIdEqualTo(sanitizedDocId).findFirst();
  // }
}

@collection
class AppRedirect {
  AppRedirect({required this.id});

  final int id;
  
  @Index()
  String? source;
  String? destination;
}
