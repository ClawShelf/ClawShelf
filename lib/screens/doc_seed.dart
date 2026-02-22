import 'dart:io';

import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/l10n/app_localizations.dart';
import 'package:claw_shelf/services/isar_open.dart';
import 'package:claw_shelf/services/sync_logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:claw_shelf/core/engine/manager/document_manager.dart';
import 'package:claw_shelf/screens/main_screen.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_plus/isar_plus.dart';
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
  // Initialize with an empty string or a fallback to prevent "LateInitializationError"
  String _statusMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial message once context is ready, but only if we haven't started yet
    if (_statusMessage.isEmpty) {
      _statusMessage = AppLocalizations.of(context)!.seedStartingUp;
      _startInitialization();
    }
  }

  // Helper to safely get localized strings within async methods
  String _getL10n(String Function(AppLocalizations) getter) {
    if (!mounted) return '';
    return getter(AppLocalizations.of(context)!);
  }

  Future<void> _startInitialization() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final localDbFile = File('${dir.path}/${DocSyncManager.dbName}.isar');
      final updateZip = File('${dir.path}/update.zip');

      // 1. Initial Seed Check
      if (!localDbFile.existsSync()) {
        if (mounted) {
          setState(
            () =>
                _statusMessage = _getL10n((l) => l.seedSeedingDocumentLibrary),
          );
        }

        final isarData = await rootBundle.load(
          'assets/${DocSyncManager.dbName}.isar',
        );
        await localDbFile.writeAsBytes(isarData.buffer.asUint8List());
      }

      // 2. Pending Update Check
      if (updateZip.existsSync()) {
        if (mounted) {
          setState(
            () => _statusMessage = _getL10n((l) => l.seedApplyLatestUpdate),
          );
        }

        await compute(_processBundleIsolate, {
          'zipPath': updateZip.path,
          'path': dir.path,
          'hash': '',
        });
        await updateZip.delete();
      }

      // 3. Open Final Instance
      if (mounted) {
        setState(
          () => _statusMessage = _getL10n((l) => l.seedLoadingDocuments),
        );
      }

      final docIsar = await openIsarSafe(
        schemas: [
          DocEntrySchema,
          AppMetadataSchema,
          AppNavigationSchema,
          AppRedirectSchema,
          AppImageSchema,
        ],
        name: DocSyncManager.dbName,
        directory: dir.path,
        inspector: MetadataKeys.inspectDocsIsar,
        onRecoveryNeeded: () async {
          if (mounted) {
            setState(
              () => _statusMessage = _getL10n(
                (l) => l.seedSeedingDocumentLibrary,
              ),
            );
          }
          final isarData = await rootBundle.load(
            'assets/${DocSyncManager.dbName}.isar',
          );
          await localDbFile.writeAsBytes(isarData.buffer.asUint8List());
        },
      );

      // 4. Register and Start Background Sync
      GetIt.I.registerSingleton<Isar>(
        docIsar,
        instanceName: MetadataKeys.docsIsarKey,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        DocSyncManager.startBackgroundDownload(docIsar, dir.path);
      });

      // 5. Navigate to Main
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CSMainScreen()),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "Error: $e");
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
