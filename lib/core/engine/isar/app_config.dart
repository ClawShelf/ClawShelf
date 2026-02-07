import 'package:isar/isar.dart';

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
