import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _pens = {
  'felt': 'felt tip',
  'pencil': 'pencil',
  'marker': 'marker',
  'highlighter': 'highlighter',
};

class ContextMenuCanvasToolsExample extends StatefulWidget {
  const ContextMenuCanvasToolsExample({super.key});

  @override
  State<ContextMenuCanvasToolsExample> createState() =>
      _ContextMenuCanvasToolsExampleState();
}

class _ContextMenuCanvasToolsExampleState
    extends State<ContextMenuCanvasToolsExample> {
  String _pen = 'felt';
  int _lines = 2;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ContextMenu(
      content: ContextMenuContent(
        width: 224,
        stock: StockName.stickyBlue,
        tape: PaperTape.corner,
        seed: 'pen-menu',
        children: [
          const ContextMenuLabel(child: Text('Pen')),
          ContextMenuRadioGroup(
            value: _pen,
            onChanged: (pen) => setState(() => _pen = pen),
            children: [
              for (final MapEntry(key: value, value: label) in _pens.entries)
                ContextMenuRadioItem(value: value, child: Text(label)),
            ],
          ),
          const ContextMenuSeparator(),
          ContextMenuGroup(
            children: [
              ContextMenuItem(
                leading: const InkIcon('plus'),
                trailing: const ContextMenuShortcut('⌘↵'),
                onSelect: () => setState(() => _lines += 1),
                child: const Text('Add a line'),
              ),
              ContextMenuItem(
                leading: const InkIcon('minus'),
                disabled: _lines < 2,
                onSelect: () =>
                    setState(() => _lines = math.max(1, _lines - 1)),
                child: const Text('Remove a line'),
              ),
            ],
          ),
        ],
      ),
      child: ContextMenuTrigger(
        child: Focus(
          child: Semantics(
            label: 'Sticky note. Press the menu key for pens.',
            child: SizedBox(
              width: 256,
              child: Paper(
                stock: StockName.stickyYellow,
                seed: 'pen-note',
                tape: PaperTape.top,
                padding: const EdgeInsets.fromLTRB(
                  Spacing.d20,
                  Spacing.d24,
                  Spacing.d20,
                  Spacing.d20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    Text(
                      'buy more ink!',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 24,
                        cssLineHeight: 1.25,
                      ),
                    ),
                    Text(
                      'written with a ${_pens[_pen]} · $_lines ${switch (_lines) {
                        1 => 'line',
                        _ => 'lines',
                      }}',
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
