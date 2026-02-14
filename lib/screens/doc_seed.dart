import 'package:flutter/material.dart';
import 'package:claw_shelf/core/engine/manager/document_manager.dart';
import 'package:claw_shelf/screens/main_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

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
    final docsIsar = await DocSyncManager.bootstrap();
    print("Document Isar Loaded");
    final getIt = GetIt.instance;

    getIt.registerSingleton<Isar>(docsIsar, instanceName: docsIsarKey);
    getIt.registerLazySingleton(
      () => DocSyncManager(getIt(instanceName: docsIsarKey)),
    );

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => CSMainScreen()));
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
