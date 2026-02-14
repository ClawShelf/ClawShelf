class MetadataKeys {
  // Database Metadata Keys
  static const String bundleVersion = 'bundle_version'; // int: timestamp
  static const String openClawSha = 'openclaw_sha'; // String: commit hash

  // JSON Manifest Keys (Matches build.json)
  static const String jsonIsarHash = 'isar_hash';
  static const String jsonZipUrl = 'zip_url';

  // debug
  static const bool inspectDocsIsar = true;

  static const docsIsarKey = 'docs_db';
  static const preferenceIsarKey = 'prefs_db';
}
