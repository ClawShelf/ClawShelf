import 'package:flutter/material.dart';
import 'package:molt_manual/screens/doc_seed.dart';

void main() {
  runApp(const MultManualApp());
}

class MultManualApp extends StatelessWidget {
  const MultManualApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Molt Manual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: MMDocSeed(),
    );
  }
}
