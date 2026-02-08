import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:molt_manual/core/engine/isar/app_config.dart';
import 'package:molt_manual/core/engine/isar/document.dart';
import 'package:molt_manual/core/engine/manager/document_manager.dart';
import 'package:molt_manual/screens/main_page.dart';
import 'package:path_provider/path_provider.dart';

class MMDocSeed extends StatefulWidget {
  const MMDocSeed({super.key});

  @override
  State<MMDocSeed> createState() => _MMDocSeedState();
}

class _MMDocSeedState extends State<MMDocSeed> {
  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // 1. Setup Environment
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open([
      DocEntrySchema,
      AppMetadataSchema,
      AppNavigationSchema,
      AppRedirectSchema,
    ], directory: dir.path);

    // 2. Initialize the Manager
    final syncManager = DocSyncManager(isar);

    // 3. Perform the MANDATORY local sync (Package -> Local)
    // We 'await' this because the app isn't usable without the base data.
    await syncManager.initLocalData();

    // // 4. Trigger the OPTIONAL remote sync (Remote -> Local)
    // // We do NOT 'await' this. It runs in its own isolate while the user navigates.
    // syncManager.startBackgroundRemoteSync();

    // 5. Navigation Handoff
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MoltManualMainPage(isar: isar)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // Your pixel-lobster spinner
            SizedBox(height: 20),
            Text("Organizing 2,400+ Skill Documents..."),
          ],
        ),
      ),
    );
  }
}
