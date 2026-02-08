import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:isar/isar.dart';
import 'package:molt_manual/core/engine/isar/document.dart';

class DocContentPage extends StatefulWidget {
  final Id id; // Pass only the Isar ID
  final Isar isar;

  const DocContentPage({super.key, required this.id, required this.isar});

  @override
  State<DocContentPage> createState() => _DocContentPageState();
}

class _DocContentPageState extends State<DocContentPage> {
  late Future<DocEntry?> _docFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching immediately, but we will handle the display carefully
    _docFuture = _fetchDocWithDelay();
  }

  Future<DocEntry?> _fetchDocWithDelay() async {
    // 1. Wait briefly for the Navigation animation to finish (approx 300ms)
    // This prevents the 'hang' because the UI thread is free to animate.
    await Future.delayed(const Duration(milliseconds: 350));

    // 2. Fetch the actual document from Isar
    return await widget.isar.docEntrys.get(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Documentation")),
      body: FutureBuilder<DocEntry?>(
        future: _docFuture,
        builder: (context, snapshot) {
          // 1. While waiting for animation/fetch, show a Skeleton/Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          }

          // 2. Handle errors or missing docs
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text("Document not found or error loading."),
            );
          }

          final doc = snapshot.data!;

          // 3. Render the heavy Markdown content
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.emoji!, style: const TextStyle(fontSize: 50)),
                const SizedBox(height: 10),
                Text(
                  doc.title!,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Divider(),
                MarkdownBody(
                  data: doc.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    code: const TextStyle(
                      backgroundColor: Color(0xFFEEEEEE),
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 60, height: 60, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Container(width: 200, height: 30, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
