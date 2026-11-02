import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _tasks = [
  (
    id: 'design',
    text: 'Design the header',
    stock: StockName.stickyYellow,
    x: 20.0,
    y: 24.0,
  ),
  (
    id: 'review',
    text: 'Review the PR',
    stock: StockName.stickyBlue,
    x: 210.0,
    y: 44.0,
  ),
  (
    id: 'ship',
    text: 'Ship it (Friday)',
    stock: StockName.stickyGreen,
    x: 60.0,
    y: 190.0,
  ),
  (
    id: 'bugs',
    text: 'Squash the 3 bugs',
    stock: StockName.stickyPink,
    x: 250.0,
    y: 200.0,
  ),
];

class CorkboardSavedLayoutExample extends StatefulWidget {
  const CorkboardSavedLayoutExample({super.key});

  @override
  State<CorkboardSavedLayoutExample> createState() =>
      _CorkboardSavedLayoutExampleState();
}

class _CorkboardSavedLayoutExampleState
    extends State<CorkboardSavedLayoutExample> {
  static const _maxWidth = 672.0;

  CorkboardValue _layout = const {};

  String get _json => jsonEncode({
    for (final MapEntry(key: id, value: at) in _layout.entries)
      id: {
        if (at.x case final x?) 'x': x.round(),
        if (at.y case final y?) 'y': y.round(),
        'r': ?at.r,
        'z': ?at.z,
      },
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          Corkboard(
            height: 340,
            value: _layout,
            onValueChange: (layout) => setState(() => _layout = layout),
            label: 'Sprint board',
            children: [
              for (final task in _tasks)
                CorkboardNote(
                  id: task.id,
                  x: task.x,
                  y: task.y,
                  stock: task.stock,
                  child: Text(task.text),
                ),
            ],
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(
                size: ButtonSize.sm,
                variant: ButtonVariant.outline,
                onPressed: () => setState(() => _layout = const {}),
                child: const Text('Reset layout'),
              ),
              Expanded(
                child: Text(
                  _json,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.mono(
                    cssSize: 12,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
