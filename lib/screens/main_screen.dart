import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/core/engine/manager/settings_repository.dart';
import 'package:claw_shelf/screens/main_screen_pages/bento_body.dart';
import 'package:claw_shelf/screens/main_screen_pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_plus/isar_plus.dart';

class CSMainScreen extends StatefulWidget {
  const CSMainScreen({super.key});

  @override
  State<CSMainScreen> createState() => _CSMainScreenState();
}

class _CSMainScreenState extends State<CSMainScreen> {
  late Isar docsIsar;
  late Isar prefsIsar;

  int _currentIndex = 0;

  final List<Widget> _pages = [CSMainPageBentoBody(), CSSettingsPage()];

  @override
  void initState() {
    super.initState();
    docsIsar = GetIt.instance(instanceName: MetadataKeys.docsIsarKey);
    prefsIsar = GetIt.instance(instanceName: MetadataKeys.preferenceIsarKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SettingsRepository.runStartupSanitySweep();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
