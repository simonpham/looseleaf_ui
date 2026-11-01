import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/kbd/kbd.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One key of a parsed shortcut: a drawn [icon] read as [text], or
/// [text].
typedef InkMenuShortcutKey = ({String? icon, String text});

/// Keys at the end of a row, drawn as keycaps: `⌘S` is two keys, `⇧⌘P`
/// three (`⌘` is the drawn command glyph, read as "Command"), `Ctrl+K`
/// two, `F2` one. [InkMenuShortcut.custom] puts any widget there instead.
///
/// Mirrors the `*MenuShortcut` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`, and `parseShortcut` in
/// `src/lib/menu-styles.ts`.
class InkMenuShortcut extends StatelessWidget {
  /// Keycaps parsed from [shortcut].
  const InkMenuShortcut(String this.shortcut, {super.key}) : child = null;

  /// [child] at the end of the row, as it is.
  const InkMenuShortcut.custom({super.key, required Widget this.child})
    : shortcut = null;

  /// The keys, as written.
  final String? shortcut;

  /// The custom content.
  final Widget? child;

  static const Map<String, InkMenuShortcutKey> _symbols = {
    '⌘': (icon: 'command', text: 'Command'),
    '⇧': (icon: null, text: 'Shift'),
    '⌥': (icon: null, text: 'Alt'),
    '⌃': (icon: null, text: 'Ctrl'),
    '↵': (icon: null, text: 'Enter'),
    '⏎': (icon: null, text: 'Enter'),
    '⌫': (icon: null, text: 'Del'),
    '⎋': (icon: null, text: 'Esc'),
    '⇥': (icon: null, text: 'Tab'),
    '␣': (icon: null, text: 'Space'),
  };

  /// Splits [input] into keys: on `+`, else on spaces, else per character
  /// when it holds a modifier symbol, else one key.
  static List<InkMenuShortcutKey> parse(String input) {
    final s = input.trim();
    if (s.isEmpty) return const [];
    final chars = s.characters.toList();
    final parts = switch (s) {
      _ when s.contains('+') && s.length > 1 =>
        s.split('+').where((part) => part.isNotEmpty).toList(),
      _ when RegExp(r'\s').hasMatch(s) => s.split(RegExp(r'\s+')),
      _ when chars.any(_symbols.containsKey) => chars,
      _ => [s],
    };
    return [
      for (final part in parts) _symbols[part] ?? (icon: null, text: part),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final custom = child;
    final keys = switch (custom) {
      null => [
        for (final key in parse(shortcut ?? ''))
          SizedBox(
            height: InkMenuMetrics.keycapHeight,
            child: Kbd(
              child: switch (key.icon) {
                final icon? => InkIcon(icon, semanticLabel: key.text),
                null => Text(key.text),
              },
            ),
          ),
      ],
      final widget => [widget],
    };
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: InkMenuMetrics.shortcutGap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d4,
        children: keys,
      ),
    );
  }
}
