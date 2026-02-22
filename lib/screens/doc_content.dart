import 'dart:io';

import 'package:claw_shelf/core/constants/keys.dart';
import 'package:claw_shelf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:claw_shelf/components/markdown/card_tag.dart';
import 'package:claw_shelf/components/markdown/fallback_element.dart';
import 'package:claw_shelf/core/engine/isar/document.dart';
import 'package:claw_shelf/services/doc_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CSDocContentPage extends StatefulWidget {
  final int id; // Pass only the Isar ID

  const CSDocContentPage({super.key, required this.id});

  @override
  State<CSDocContentPage> createState() => _CSDocContentPageState();
}

class _CSDocContentPageState extends State<CSDocContentPage> {
  late Future<DocEntry?> _docFuture;

  late Isar docsIsar;
  late final String localDocsImagePath;

  @override
  void initState() {
    super.initState();

    docsIsar = GetIt.instance(instanceName: MetadataKeys.docsIsarKey);
    // Start fetching immediately, but we will handle the display carefully
    _docFuture = _fetchDocWithDelay();
  }

  Future<DocEntry?> _fetchDocWithDelay() async {
    // 1. Wait briefly for the Navigation animation to finish (approx 300ms)
    // This prevents the 'hang' because the UI thread is free to animate.
    await Future.delayed(const Duration(milliseconds: 350));

    final docDir = await getApplicationDocumentsDirectory();
    // Ensure this matches the 'targetPath/images' you used in SyncLogic
    localDocsImagePath = '${docDir.path}/images';

    // 2. Fetch the actual document from Isar
    return docsIsar.docEntrys.get(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.docDocumentation),
      ),
      body: FutureBuilder<DocEntry?>(
        future: _docFuture,
        builder: (context, snapshot) {
          // 1. While waiting for animation/fetch, show a Skeleton/Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader(context);
          }

          // 2. Handle errors or missing docs
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text("Document not found or error loading."),
            );
          }

          final doc = snapshot.data!;

          // Inside your DocReaderPage
          String sanitizedContent = doc.content
              .replaceAll(RegExp(r'<p[^>]*>'), '')
              .replaceAll('</p>', '');

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
                  data: sanitizedContent,
                  selectable: true,
                  imageBuilder: (uri, title, alt) {
                    final fileName = uri.path;

                    // 1. Construct the path to the local (synced) file
                    final localFile = File('$localDocsImagePath/$fileName');

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: localFile.existsSync()
                          ? Image.file(
                              localFile,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            )
                          : Image.asset(
                              'assets/images/$fileName', // Fallback to bundle if not in local storage
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                    );
                  },
                  extensionSet: md.ExtensionSet(
                    [
                      const CardBlockSyntax(),
                      ...md.ExtensionSet.gitHubWeb.blockSyntaxes,
                    ],
                    [...md.ExtensionSet.gitHubWeb.inlineSyntaxes],
                  ),
                  builders: {
                    "Card": CardWidgetBuilder(context),
                    'UnknownTag': FallbackTagBuilder(),
                  },
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      handleInternalLink(href, context);
                    }
                  },
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    code: TextStyle(
                      // 🔥 POP LOGIC:
                      // Light Mode: White text on dark "pills" (keep as is, it looks great)
                      // Dark Mode: Brighter, bold lavender/purple to make it glow
                      color: theme.brightness == Brightness.light
                          ? Colors.white
                          : theme
                                .colorScheme
                                .primary, // Use a lighter/brighter variant
                      backgroundColor: theme.brightness == Brightness.light
                          ? const Color(0xFF424242)
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.15,
                            ),
                      fontWeight: theme.brightness == Brightness.dark
                          ? FontWeight
                                .w500 // Slightly thicker in dark mode to prevent "bleeding"
                          : FontWeight.normal,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors
                                .black // Pure black makes the code text pop more than grey
                          : const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ) // Branded border
                            : theme.colorScheme.outlineVariant.withValues(
                                alpha: 0.2,
                              ),
                      ),
                    ),
                    p: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    // Optional: Match the H1/H2 colors to your primary brand color
                    h1: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
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

  void handleInternalLink(String href, BuildContext context) async {
    // 1. Skip external URLs
    if (href.startsWith('http')) {
      final url = Uri.parse(href);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      // Use url_launcher to open in browser
      return;
    }

    CSDocNavigation.navigateToDoc(context, href);
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define a base color that works for both modes
    // In light mode: a light grey
    // In dark mode: a subtle charcoal/grey
    final Color baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : Colors.grey[300]!;

    final Color highlightColor = isDark
        ? theme.colorScheme.surfaceContainer
        : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon/Image Placeholder
          _skeletonBox(width: 60, height: 60, color: baseColor),
          const SizedBox(height: 20),
          // Title Placeholder
          _skeletonBox(width: 200, height: 30, color: baseColor),
          const SizedBox(height: 20),
          // Content Lines
          _skeletonBox(
            width: double.infinity,
            height: 20,
            color: highlightColor,
          ),
          const SizedBox(height: 10),
          _skeletonBox(
            width: double.infinity,
            height: 20,
            color: highlightColor,
          ),
          const SizedBox(height: 10),
          _skeletonBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 20,
            color: highlightColor,
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          8,
        ), // Rounded corners match your Bento cards
      ),
    );
  }
}
