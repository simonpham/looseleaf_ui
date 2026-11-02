import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupViewSwitcherExample extends StatefulWidget {
  const ToggleGroupViewSwitcherExample({super.key});

  @override
  State<ToggleGroupViewSwitcherExample> createState() =>
      _ToggleGroupViewSwitcherExampleState();
}

class _ToggleGroupViewSwitcherExampleState
    extends State<ToggleGroupViewSwitcherExample> {
  static const _sketches = [
    'Snail on a leaf',
    'Teapot, three ways',
    'The corner of the desk',
    'Rain at 7 a.m.',
  ];
  static const _maxWidth = 448.0;
  static const _numberWidth = 20.0;

  var _view = 'list';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'views',
          children: [
            CardHeader(
              children: [
                const CardTitle(Text('Sketchbook')),
                CardDescription(
                  Text(
                    'Showing ${switch (_view) {
                      'grid' => 'a grid',
                      'menu' => 'compact rows',
                      _ => 'a list',
                    }} of four pages.',
                  ),
                ),
                CardAction(
                  child: ToggleGroup<String>(
                    variant: ToggleVariant.outline,
                    size: ToggleSize.sm,
                    value: {_view},
                    onChanged: (value) {
                      if (value.firstOrNull case final view?) {
                        setState(() => _view = view);
                      }
                    },
                    semanticLabel: 'View',
                    children: const [
                      ToggleGroupItem(
                        value: 'list',
                        semanticLabel: 'List',
                        child: InkIcon('list'),
                      ),
                      ToggleGroupItem(
                        value: 'grid',
                        semanticLabel: 'Grid',
                        child: InkIcon('layout-grid'),
                      ),
                      ToggleGroupItem(
                        value: 'menu',
                        semanticLabel: 'Compact',
                        child: InkIcon('menu'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            CardContent(
              child: switch (_view) {
                'grid' => LayoutBuilder(
                  builder: (context, constraints) => Wrap(
                    spacing: Spacing.d12,
                    runSpacing: Spacing.d12,
                    children: [
                      for (final sketch in _sketches)
                        SizedBox(
                          width: (constraints.maxWidth - Spacing.d12) / 2,
                          height: Spacing.d64,
                          child: Paper(
                            stock: StockName.slip,
                            seed: sketch,
                            padding: const EdgeInsets.all(Spacing.d8),
                            child: Align(
                              alignment: AlignmentDirectional.bottomStart,
                              child: Text(
                                sketch,
                                style: theme.typography.face(
                                  KevinSansFace.hand,
                                  cssSize: 14,
                                  cssLineHeight: 1.25,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _ => DefaultTextStyle.merge(
                  style: switch (_view) {
                    'menu' => theme.typography.interface(cssSize: 15),
                    _ => const TextStyle(),
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: switch (_view) {
                      'menu' => Spacing.d4,
                      _ => Spacing.d12,
                    },
                    children: [
                      for (final (index, sketch) in _sketches.indexed)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          spacing: Spacing.d12,
                          children: [
                            SizedBox(
                              width: _numberWidth,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: theme.colors.inkMuted),
                              ),
                            ),
                            Expanded(child: Text(sketch)),
                          ],
                        ),
                    ],
                  ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
