import 'package:isar/isar.dart';
import 'package:molt_manual/core/engine/isar/document.dart';

part 'app_config.g.dart';

@collection
class AppNavigation {
  Id id = Isar.autoIncrement;

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

  Future<DocEntry?> fetchDoc(Isar isar) async {
    if (path == null || path!.isEmpty) return null;

    // 1. Normalize the input path to match your JSON redirect format
    // If your NavNode path is "model_failover", but JSON is "/model-failover"
    String lookupPath = path!.startsWith('/')
        ? path!
        : '/${path!.replaceAll('_', '/')}';

    // 2. Query the Redirect table
    final redirect = await isar.appRedirects
        .filter()
        .sourceEqualTo(lookupPath)
        .findFirst();

    // 3. Determine the final destination
    String finalPath = redirect != null ? redirect.destination : lookupPath;

    // 4. Convert the destination back to the Isar DocID format
    // Example: "/concepts/model-failover" -> "concepts_model-failover"
    String sanitizedDocId = finalPath
        .replaceFirst('/', '') // Remove leading slash
        .replaceAll('/', '_'); // Slashes to underscores

    return await isar.docEntrys
        .filter()
        .docIdEqualTo(sanitizedDocId)
        .findFirst();
  }
}

@collection
class AppRedirect {
  Id id = Isar.autoIncrement;
  @Index()
  late String source;
  late String destination;
}

// // Logic to check before navigating:
// final redirect = await isar.appRedirects.filter().sourceEqualTo(requestedPath).findFirst();
// final finalPath = redirect?.destination ?? requestedPath;
