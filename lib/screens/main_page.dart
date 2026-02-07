import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class MoltManualMainPage extends StatefulWidget {
  const MoltManualMainPage({super.key, required this.isar});
  final Isar isar;

  @override
  State<MoltManualMainPage> createState() => _MoltManualMainPageState();
}

class _MoltManualMainPageState extends State<MoltManualMainPage> {
  Future<void> loadIndex() async {
    // Initial Isar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Search...",
          ),
        ),
      ),
      body: FutureBuilder(
        future: loadIndex(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
