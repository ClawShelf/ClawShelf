import 'dart:io';

import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/services/sync_logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:claw_shelf/core/engine/manager/document_manager.dart';
import 'package:claw_shelf/screens/main_screen.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// This runs in a separate Isolate to prevent UI jank during extraction
Future<void> _processBundleIsolate(Map<String, dynamic> args) async {
  final file = File(args['zipPath']);
  final bytes = await file.readAsBytes();
  await SyncLogic.processBundle(
    zipBytes: bytes,
    targetPath: args['path'],
    expectedHash: args['hash'], // Pass empty string if already verified
  );
}

class CSDocSeedScreen extends StatefulWidget {
  const CSDocSeedScreen({super.key});

  @override
  State<CSDocSeedScreen> createState() => _CSDocSeedScreenState();
}

class _CSDocSeedScreenState extends State<CSDocSeedScreen> {
  String _statusMessage = "Starting up...";

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final localDbFile = File('${dir.path}/${DocSyncManager.dbName}.isar');
      final updateZip = File('${dir.path}/update.zip');

      // 1. Initial Seed Check
      if (!localDbFile.existsSync()) {
        setState(() => _statusMessage = "Seeding document library...");
        final isarData = await rootBundle.load(
          'assets/${DocSyncManager.dbName}.isar',
        );
        await localDbFile.writeAsBytes(isarData.buffer.asUint8List());
      }

      // 2. Pending Update Check
      if (updateZip.existsSync()) {
        setState(() => _statusMessage = "Applying latest updates...");
        await compute(_processBundleIsolate, {
          'zipPath': updateZip.path,
          'path': dir.path,
          'hash': '', // We already verified this during the download phase
        });
        await updateZip.delete();
      }

      // 3. Open Final Instance
      setState(() => _statusMessage = "Loading documents...");
      final isar = await Isar.open(
        [
          DocEntrySchema,
          AppMetadataSchema,
          AppNavigationSchema,
          AppRedirectSchema,
          AppImageSchema,
        ],
        name: DocSyncManager.dbName,
        directory: dir.path,
        inspector: MetadataKeys.inspectDocsIsar,
      );

      // 4. Register and Start Background Sync
      GetIt.I.registerSingleton<Isar>(
        isar,
        instanceName: MetadataKeys.docsIsarKey,
      );

      // We don't await this; it runs in the background while the user is in the app
      DocSyncManager.startBackgroundDownload(isar, dir.path);

      // 5. Navigate to Main
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => CSMainScreen()));
      }
    } catch (e) {
      setState(() => _statusMessage = "Error: $e");
      // You might want to add a "Retry" button here for robustness
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}
