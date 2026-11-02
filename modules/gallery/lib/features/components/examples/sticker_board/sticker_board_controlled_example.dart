import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerBoardControlledExample extends StatefulWidget {
  const StickerBoardControlledExample({super.key});

  @override
  State<StickerBoardControlledExample> createState() =>
      _StickerBoardControlledExampleState();
}

class _StickerBoardControlledExampleState
    extends State<StickerBoardControlledExample> {
  static const _names = [
    'rocket',
    'cloud-smile',
    'first-place',
    'stamp-approved',
  ];
  static const double _canvasHeight = Spacing.d176 * 2;
  static const double _valueWidth = Spacing.d256;
  static const double _twoColumnsFrom = Spacing.d256 * 2;

  final _firstAdd = FocusNode();
  List<StickerBoardItem> _items = StickerBoardOps.add(
    const [],
    'rocket',
    x: 120,
    y: 110,
    rot: -10,
  );

  @override
  void dispose() {
    _firstAdd.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() => _items = const []);
    _firstAdd.requestFocus();
  }

  Widget _board(double width) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d12,
    children: [
      StickerBoard(
        value: _items,
        onValueChange: (items) => setState(() => _items = items),
        size: Spacing.d80 + Spacing.d8,
        children: const [
          StickerBoardCanvas(
            height: _canvasHeight,
            empty: Text('Press a button to stick something down.'),
          ),
        ],
      ),
      Wrap(
        spacing: Spacing.d8,
        runSpacing: Spacing.d8,
        children: [
          for (final (index, name) in _names.indexed)
            Button(
              focusNode: switch (index) {
                0 => _firstAdd,
                _ => null,
              },
              size: ButtonSize.sm,
              variant: ButtonVariant.outline,
              onPressed: () => setState(
                () => _items = StickerBoardOps.add(
                  _items,
                  name,
                  canvas: Size(width, _canvasHeight),
                ),
              ),
              child: Text('Add ${name.replaceFirst('-', ' ')}'),
            ),
          Button(
            size: ButtonSize.sm,
            variant: ButtonVariant.ghost,
            disabled: _items.isEmpty,
            onPressed: _clear,
            child: const Text('Clear'),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final value = Paper(
      stock: StockName.slip,
      tilt: false,
      padding: const EdgeInsets.all(Spacing.d12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _canvasHeight),
        child: SingleChildScrollView(
          child: Semantics(
            label: 'Board value',
            child: Text(
              const JsonEncoder.withIndent(
                ' ',
              ).convert([for (final item in _items) item.toJson()]),
              style: theme.typography.mono(
                cssSize: 12,
                color: theme.colors.ink,
              ),
            ),
          ),
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _twoColumnsFrom) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d16,
            children: [_board(constraints.maxWidth), value],
          );
        }
        final boardWidth = constraints.maxWidth - _valueWidth - Spacing.d16;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            Expanded(child: _board(boardWidth)),
            SizedBox(width: _valueWidth, child: value),
          ],
        );
      },
    );
  }
}
