import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/services/doc_navigation.dart';

class CardWidgetBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final Isar isar;

  CardWidgetBuilder(this.context, {required this.isar});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final title = element.attributes['title'] ?? 'No Title';
    final iconName = element.attributes['icon'] ?? 'description';
    final href = element.attributes['href']; // Extract the href attribute
    final content = element.textContent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        // Added Material for InkWell splash effects
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: href != null ? () => _handleNavigation(href) : null,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_getIcon(iconName), color: Colors.orange, size: 28),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String path) {
    // Implement your navigation logic here.
    // Example: Use GoRouter or standard Navigator to find the docId from the path
    debugPrint("Navigating to: $path");

    // If the path is /start/wizard, you'd find the doc with docPath "start/wizard.md"
    // and push a new DocReaderPage.

    // Remove leading slash and find the matching doc
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // // Logic to find the doc entry by path (e.g., matching against 'start/wizard.md')
    // final targetDoc = allDocs.firstWhere(
    //   (d) => d.docPath.contains(cleanPath),
    //   orElse: () => null
    // );

    final targetDoc = isar.docEntrys
        .filter()
        .docIdEqualTo(cleanPath.replaceAll('/', '_'))
        .findFirstSync();

    if (targetDoc != null) {
      CSDocNavigation.open(context, isar, targetDoc);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => DocReaderPage(doc: targetDoc)),
      // );
    }
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'rocket':
        return Icons.rocket_launch_outlined;
      case 'sparkles':
        return Icons.auto_awesome_outlined;
      case 'layout-dashboard':
        return Icons.dashboard_outlined;
      case 'network':
        return Icons.hub_outlined;
      case 'plug':
        return Icons.power_outlined;
      case 'route':
        return Icons.route_outlined;
      case 'monitor':
        return Icons.monitor_outlined;
      case 'smartphone':
        return Icons.smartphone_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}

class CardBlockSyntax extends md.BlockSyntax {
  // Regex to identify the start of a Card block
  @override
  RegExp get pattern => RegExp(r'^<Card\s+([^>]+)>');

  const CardBlockSyntax();

  @override
  md.Node parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content)!;
    final attributesLine = match.group(1) ?? "";

    // Move the parser forward
    parser.advance();

    // Capture everything until the closing </Card> tag
    final childLines = <String>[];
    while (!parser.isDone && !parser.current.content.contains('</Card>')) {
      childLines.add(parser.current.content);
      parser.advance();
    }

    // Advance past the closing tag
    if (!parser.isDone) parser.advance();

    // Create the Element that will be passed to your Builder
    final element = md.Element('Card', [md.Text(childLines.join('\n').trim())]);

    // Parse the attributes (title, icon, href) and add them to the element
    _parseAttributes(attributesLine, element);

    return element;
  }

  void _parseAttributes(String attributesLine, md.Element element) {
    final attrRegex = RegExp(r'(\w+)="([^"]+)"');
    for (final match in attrRegex.allMatches(attributesLine)) {
      element.attributes[match.group(1)!] = match.group(2)!;
    }
  }
}
