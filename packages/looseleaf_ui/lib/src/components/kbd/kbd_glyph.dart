import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';

/// A key symbol no bundled font has (`⌘`, `⇧`, `⌥`, `⌃`, `↵`), drawn in
/// pencil at the ambient icon size and color so it shows on every
/// platform. [Kbd] swaps a [Text] holding one of these for it.
///
/// ```dart
/// const Kbd(child: KbdGlyph('⇧'))
/// ```
class KbdGlyph extends StatelessWidget {
  const KbdGlyph(this.symbol, {super.key, this.color});

  /// The drawn symbols and what a screen reader says for each.
  static final Map<String, ({ArtDef art, String label})> symbols = {
    '⌘': (art: icons['command'] ?? _shift, label: 'Command'),
    '⇧': (art: _shift, label: 'Shift'),
    '⌥': (art: _option, label: 'Option'),
    '⌃': (art: _control, label: 'Control'),
    '↵': (art: _enter, label: 'Enter'),
    '⏎': (art: _enter, label: 'Enter'),
  };

  /// One of [symbols]; anything else is drawn as text.
  final String symbol;

  /// The ink; the ambient icon or text color when null.
  final Color? color;

  static const ArtDef _shift = ArtDef(
    grid: ArtGrid.icon,
    kind: ArtKind.icon,
    parts: [
      StrokePart(
        'M12 3.7 L20.3 12.3 L15.6 12.4 L15.5 20.2 L8.4 20.3 L8.5 12.4 '
        'L3.7 12.2 Z',
      ),
    ],
  );

  static const ArtDef _option = ArtDef(
    grid: ArtGrid.icon,
    kind: ArtKind.icon,
    parts: [
      StrokePart('M3.6 6.6 L8.9 6.5 L15.2 17.5 L20.4 17.4'),
      StrokePart('M14.5 6.5 L20.4 6.6', 0.95),
    ],
  );

  static const ArtDef _control = ArtDef(
    grid: ArtGrid.icon,
    kind: ArtKind.icon,
    parts: [StrokePart('M5.4 14.6 L12 7.6 L18.6 14.5')],
  );

  static const ArtDef _enter = ArtDef(
    grid: ArtGrid.icon,
    kind: ArtKind.icon,
    parts: [
      StrokePart('M19.6 4.6 L19.5 13.4 L5.2 13.5'),
      StrokePart('M9.2 9.3 L5 13.5 L9.3 17.6', 0.95),
    ],
  );

  static const double _fallbackSize = 14;

  /// InkIcon's weight for small `ui` icons, so the glyphs match drawn
  /// icons beside them.
  static const double _weight = 1.12;

  @override
  Widget build(BuildContext context) {
    final entry = symbols[symbol];
    if (entry == null) return Text(symbol);
    final ambient = IconTheme.of(context).size;
    final px = math
        .max(8, JsMath.roundInt(ambient ?? _fallbackSize))
        .toDouble();
    final nib =
        math.min(3.4, math.max(1.45, px * (entry.art.nibK ?? 0.068))) * _weight;
    return InkArt(
      cacheKey: 'kbd|$symbol|${JsMath.numberToString(px)}',
      draw: () => drawSkeleton(
        entry.art,
        px,
        'kbd-$symbol',
        DrawOpts(tone: ArtTone.ui, kind: ArtKind.icon, nib: nib),
      ).result,
      size: Size.square(px),
      color: color,
      semanticLabel: entry.label,
    );
  }
}
