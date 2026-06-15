import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '/data/models/manual_section.dart';
import '/shared/utils/manual_search.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/expandable_panel_theme.dart';
import '/shared/widgets/html_content_view.dart';

/// Searchable table-of-contents style manual reader with full-text fuzzy search.
class ManualSectionsList extends StatefulWidget {
  const ManualSectionsList({
    super.key,
    required this.sections,
  });

  final List<ManualSection> sections;

  @override
  State<ManualSectionsList> createState() => _ManualSectionsListState();
}

class _ManualSectionsListState extends State<ManualSectionsList> {
  final _searchController = TextEditingController();
  String _query = '';

  List<ManualSearchResult> get _results =>
      searchManualSections(widget.sections, _query);

  bool get _isSearching => _query.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _results;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search all manual content…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        if (_isSearching) ...[
          const SizedBox(height: 8),
          Text(
            results.isEmpty
                ? 'No matches'
                : '${results.length} matching section${results.length == 1 ? '' : 's'}',
            style: theme.textTheme.labelSmall,
          ),
        ],
        const SizedBox(height: 16),
        if (results.isEmpty)
          EmptyState(
            title: 'No matching sections',
            message: _query.isEmpty
                ? 'Manual sections are not available yet.'
                : 'Try different words or check spelling — search covers all section text.',
          )
        else
          ...results.map(
            (result) => _ManualSectionTile(
              section: result.section,
              snippet: result.snippet,
              highlightTerms: result.matchedTerms,
              initiallyExpanded: _isSearching,
            ),
          ),
      ],
    );
  }
}

class _ManualSectionTile extends StatelessWidget {
  const _ManualSectionTile({
    required this.section,
    this.snippet,
    this.highlightTerms = const [],
    this.initiallyExpanded = false,
  });

  final ManualSection section;
  final String? snippet;
  final List<String> highlightTerms;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseSnippetStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
      fontStyle: FontStyle.italic,
      height: 1.5,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpandableNotifier(
        initialExpanded: initiallyExpanded,
        child: ExpandablePanel(
          theme: paediaExpandableTheme(context),
          header: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: theme.textTheme.titleSmall,
                ),
                if (snippet != null && baseSnippetStyle != null) ...[
                  const SizedBox(height: 6),
                  RichText(
                    text: _highlightSpan(
                      text: snippet!,
                      terms: highlightTerms,
                      baseStyle: baseSnippetStyle,
                      theme: theme,
                    ),
                  ),
                ],
              ],
            ),
          ),
          collapsed: const SizedBox.shrink(),
          expanded: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: HtmlContentView(html: section.html),
          ),
        ),
      ),
    );
  }

  TextSpan _highlightSpan({
    required String text,
    required List<String> terms,
    required TextStyle baseStyle,
    required ThemeData theme,
  }) {
    if (terms.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final pattern =
        terms.where((term) => term.isNotEmpty).map(RegExp.escape).join('|');

    if (pattern.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final regex = RegExp('($pattern)', caseSensitive: false);
    final spans = <TextSpan>[];
    var start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: baseStyle.copyWith(
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return TextSpan(children: spans);
  }
}
