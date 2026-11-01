import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _shortcuts = [
  (what: 'Open the command palette', keys: ['Ctrl', 'K']),
  (what: 'Save the page', keys: ['Ctrl', 'S']),
  (what: 'Toggle the sidebar', keys: ['Ctrl', 'B']),
  (what: 'Find in page', keys: ['Ctrl', 'F']),
  (what: 'Close whatever is open', keys: ['Esc']),
];

/// `max-w-md`.
const _maxWidth = 448.0;

class KbdShortcutSheetExample extends StatelessWidget {
  const KbdShortcutSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final plus = Text(
      '+',
      style: theme.typography.interface(
        cssSize: 14,
        color: theme.colors.inkMuted,
      ),
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'shortcuts',
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Keyboard shortcuts')),
                CardDescription(
                  Text('Everything you can do without lifting a hand.'),
                ),
              ],
            ),
            CardContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d16,
                children: [
                  const Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      Input(
                        placeholder: 'Search shortcuts',
                        semanticLabel: 'Search shortcuts',
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: Spacing.d12),
                        child: IgnorePointer(child: Kbd(child: Text('/'))),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (index, shortcut) in _shortcuts.indexed) ...[
                        if (index > 0)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: Spacing.d8),
                            child: Separator(variant: SeparatorVariant.dashed),
                          ),
                        Row(
                          spacing: Spacing.d16,
                          children: [
                            Expanded(
                              child: Text(
                                shortcut.what,
                                style: theme.typography.interface(cssSize: 15),
                              ),
                            ),
                            KbdGroup(
                              children: [
                                for (final (keyIndex, key)
                                    in shortcut.keys.indexed) ...[
                                  if (keyIndex > 0) plus,
                                  Kbd(child: Text(key)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
