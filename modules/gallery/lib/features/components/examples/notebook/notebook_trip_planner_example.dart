import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

/// `min-h-[24rem]`.
const _minHeight = 384.0;

const _items = [
  'Passport, tickets, the good pen',
  'Waterproof notebook',
  'Two rolls of washi tape',
  'Tea (a lot)',
  'The very small pencil',
];

class NotebookTripPlannerExample extends StatefulWidget {
  const NotebookTripPlannerExample({super.key});

  @override
  State<NotebookTripPlannerExample> createState() =>
      _NotebookTripPlannerExampleState();
}

class _NotebookTripPlannerExampleState
    extends State<NotebookTripPlannerExample> {
  final Set<int> _packed = {0, 1};

  void _toggle(int index) => setState(() {
    if (_packed.remove(index)) return;
    _packed.add(index);
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Semantics(
          container: true,
          label: 'Packing list',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Notebook(
                binding: NotebookBinding.rings,
                pages: 3,
                seed: 'trip',
                minHeight: _minHeight,
                children: [
                  NotebookPage(
                    children: [
                      const NotebookTitle(Text('Packing list')),
                      for (final (index, item) in _items.indexed)
                        SizedBox(
                          height: Spacing.d28,
                          child: Row(
                            spacing: Spacing.d12,
                            children: [
                              Checkbox(
                                value: _packed.contains(index),
                                onChanged: (_) => _toggle(index),
                                semanticLabel: item,
                              ),
                              Expanded(
                                child: Label(
                                  onPressed: () => _toggle(index),
                                  child: Text(
                                    item,
                                    style: theme.typography.face(
                                      KevinSansFace.hand,
                                      cssSize: 17,
                                      cssLineHeight: 28 / 17,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const PositionedDirectional(
                top: -Spacing.d16,
                end: -Spacing.d12,
                child: Sticker('done', size: Spacing.d64, rotate: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
