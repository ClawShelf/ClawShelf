class MetadataKeys {
  // Database Metadata Keys
  static const String bundleVersion = 'bundle_version'; // int: timestamp
  static const String openClawSha = 'openclaw_sha'; // String: commit hash
  static const String buildDate = 'build_date'; // int: ms epoch

  // JSON Manifest Keys (Matches build.json)
  static const String jsonIsarHash = 'isar_hash';
  static const String jsonZipUrl = 'zip_url';
}

bool inspectDocsIsar = true;