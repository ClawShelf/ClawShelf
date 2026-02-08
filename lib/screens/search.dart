import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:molt_manual/core/engine/isar/document.dart';
import 'package:molt_manual/services/doc_navigation.dart';

class MMSearchPage extends StatefulWidget {
  final Isar isar;
  final String lang;

  const MMSearchPage({super.key, required this.isar, required this.lang});

  @override
  State<MMSearchPage> createState() => _MMSearchPageState();
}

class _MMSearchPageState extends State<MMSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<DocEntry> _results = [];
  Timer? _debounce;

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() => _results = []);
        return;
      }

      // Query across title, summary, and full content
      final results = await widget.isar.docEntrys
          .filter()
          .langEqualTo(widget.lang) // Localization filter
          .and()
          .group(
            (q) => q
                .titleContains(query, caseSensitive: false)
                .or()
                .summaryContains(query, caseSensitive: false)
                .or()
                .contentContains(query, caseSensitive: false),
          )
          .limit(40) // Limit for performance
          .findAll();

      setState(() => _results = results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'search_bar',
          child: Material(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onSearch,
              decoration: const InputDecoration(hintText: 'Search docs...'),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final doc = _results[index];
          return ListTile(
            leading: Text(doc.emoji ?? "📄"),
            title: Text(doc.title ?? ""),
            subtitle: Text(doc.summary ?? "", maxLines: 1),
            onTap: () => MMDocNavigation.open(context, widget.isar, doc),
          );
        },
      ),
    );
  }
}
