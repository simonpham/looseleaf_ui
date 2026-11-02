import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/empty_search/empty_search.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A contacts card searched for something nobody is called: Stubby with a
/// magnifier, a way to clear the search, and a few names to try.
///
/// Mirrors upstream `src/blocks/empty-search/page.tsx`.
class EmptySearchBlock extends StatefulWidget {
  const EmptySearchBlock({super.key, this.defaultQuery = 'ghost pepper'});

  final String defaultQuery;

  @override
  State<EmptySearchBlock> createState() => _EmptySearchBlockState();
}

class _EmptySearchBlockState extends State<EmptySearchBlock> {
  static const _suggestions = ['Ada', 'Printer', 'Lagos'];
  static const double _maxWidth = 672;
  static const double _wideFrom = 576;

  late final _query = TextEditingController(text: widget.defaultQuery);
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _query.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _set(String value) {
    setState(() => _query.text = value);
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final query = _query.text;
    final people = findEmptySearchPeople(query);
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.d32,
          vertical: switch (constraints.maxWidth >= _wideFrom) {
            true => Spacing.d56,
            false => Spacing.d40,
          },
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Card(
              tape: PaperTape.corner,
              seed: 'empty-search',
              children: [
                CardHeader(
                  children: [
                    const CardTitle(Text('Contacts')),
                    CardDescription(
                      Text(
                        '${emptySearchPeople.length} people in your address '
                        'book',
                      ),
                    ),
                  ],
                ),
                CardContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d16,
                    children: [
                      InputGroup(
                        focusNode: _searchFocus,
                        semanticLabel: 'Search contacts',
                        children: [
                          const InputGroupAddon(child: InkIcon('search')),
                          InputGroupInput(
                            controller: _query,
                            placeholder: 'Search by name or place',
                            onChanged: (_) => setState(() {}),
                          ),
                          if (query.isNotEmpty)
                            InputGroupAddon(
                              align: InputGroupAlign.inlineEnd,
                              child: InputGroupButton(
                                size: InputGroupButtonSize.iconXs,
                                semanticLabel: 'Clear search',
                                onPressed: () => _set(''),
                                child: const InkIcon('x'),
                              ),
                            ),
                        ],
                      ),
                      Semantics(
                        container: true,
                        liveRegion: true,
                        label: switch (people.length) {
                          0 => 'No results.',
                          1 => '1 person found.',
                          final count => '$count people found.',
                        },
                        child: switch (people.isEmpty) {
                          false => EmptySearchList(people: people),
                          true => Empty(
                            framed: true,
                            children: [
                              EmptyHeader(
                                children: [
                                  const EmptyMedia(pose: 'search', size: 120),
                                  EmptyTitle(
                                    child: Text(
                                      'No results for “${query.trim()}”',
                                    ),
                                  ),
                                  const EmptyDescription(
                                    child: Text(
                                      'Nobody is called that. Check the '
                                      'spelling, or try a shorter word.',
                                    ),
                                  ),
                                ],
                              ),
                              EmptyContent(
                                children: [
                                  Button(
                                    onPressed: () => _set(''),
                                    child: const Text('Clear search'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: Spacing.d8,
                                    ),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: Spacing.d12,
                                      runSpacing: Spacing.d8,
                                      children: [
                                        Text(
                                          'Try',
                                          style: theme.typography.face(
                                            KevinSansFace.hand,
                                            cssSize: 14,
                                            color: theme.colors.inkMuted,
                                          ),
                                        ),
                                        for (final suggestion in _suggestions)
                                          Button(
                                            variant: ButtonVariant.outline,
                                            size: ButtonSize.sm,
                                            onPressed: () => _set(suggestion),
                                            child: Text(suggestion),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
