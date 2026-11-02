import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyNoResultsExample extends StatefulWidget {
  const EmptyNoResultsExample({super.key});

  @override
  State<EmptyNoResultsExample> createState() => _EmptyNoResultsExampleState();
}

class _EmptyNoResultsExampleState extends State<EmptyNoResultsExample> {
  static const _people = [
    'Ada Lovelace',
    'Jo Okafor',
    'Mika Kobayashi',
    'Sam Reyes',
    'Priya Nair',
    'Tomas Berg',
  ];

  final _query = TextEditingController(text: 'ghost pepper');

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final needle = _query.text.trim().toLowerCase();
    final shown = [
      for (final person in _people)
        if (person.toLowerCase().contains(needle)) person,
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Card(
        seed: 'contacts',
        children: [
          const CardHeader(children: [CardTitle(Text('Contacts'))]),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d16,
              children: [
                Input(
                  controller: _query,
                  placeholder: 'Search by name',
                  semanticLabel: 'Search contacts',
                ),
                switch (shown) {
                  [] => Empty(
                    padding: const EdgeInsets.all(Spacing.d16),
                    children: [
                      EmptyHeader(
                        children: [
                          const EmptyMedia(pose: 'shrug', size: 104),
                          const EmptyTitle(child: Text('No contacts found')),
                          EmptyDescription(
                            child: Text(
                              'Nobody is called “${_query.text}”. Check the spelling, or start again.',
                            ),
                          ),
                        ],
                      ),
                      EmptyContent(
                        children: [
                          Button(
                            size: ButtonSize.sm,
                            variant: ButtonVariant.outline,
                            onPressed: _query.clear,
                            child: const Text('Show everyone'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _ => Semantics(
                    label: 'Contacts',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d8,
                      children: [
                        for (final person in shown)
                          Text(
                            person,
                            style: theme.typography.interface(cssSize: 14),
                          ),
                      ],
                    ),
                  ),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}
