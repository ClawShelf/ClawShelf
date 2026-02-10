import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:claw_shelf/core/engine/isar/app_config.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/core/engine/manager/document_manager.dart';
import 'package:claw_shelf/screens/main_screen.dart';
import 'package:path_provider/path_provider.dart';

class CSDocSeedScreen extends StatefulWidget {
  const CSDocSeedScreen({super.key});

  @override
  State<CSDocSeedScreen> createState() => _CSDocSeedScreenState();
}

class _CSDocSeedScreenState extends State<CSDocSeedScreen> {
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
        MaterialPageRoute(builder: (_) => CSMainScreen(isar: isar)),
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
            Text("Organizing Documents..."),
          ],
        ),
      ),
    );
  }
}
