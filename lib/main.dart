import 'package:flutter/material.dart';
import 'package:claw_shelf/screens/doc_seed.dart';

void main() {
  runApp(const ClawShelfApp());
}

class ClawShelfApp extends StatelessWidget {
  const ClawShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClawShelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: CSDocSeedScreen(),
    );
  }
}
