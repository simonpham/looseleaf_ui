import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Which end caps a range band cell has.
enum CalendarBandKind {
  /// No caps: the swipe runs through.
  mid,

  /// Capped at the reading start.
  start,

  /// Capped at the reading end.
  end,

  /// Capped at both ends.
  pill,
}

/// The day marks of `calendarCss`, parsed for painting: the selection
/// rings and washes, today's underlines, the hatch, the focus loop and the
/// range band cells.
///
/// Upstream lays colours through them as CSS masks
/// (`src/lib/ink/recipes/calendar-ink.ts`); here the same markup is
/// painted and the colour laid through it.
class CalendarTiles {
  CalendarTiles._()
    : rings = [
        for (var i = 0; i < ringHands; i++) _parse(ringTile('cal|ring|$i')),
      ],
      washes = [
        for (var i = 0; i < ringHands; i++) _parse(washTile('cal|wash|$i')),
      ],
      underlines = [
        for (var i = 0; i < underlineHands; i++)
          _parse(underlineTile('cal|under|$i', i == 1)),
      ],
      hatch = _parse(hatchTile('cal|hatch')),
      focus = _parse(focusTile('cal|focus')),
      bands = [
        for (var f = 0; f < bandFrames; f++)
          {
            for (final kind in CalendarBandKind.values)
              kind: _parse(
                bandTile(
                  'cal|band|$f',
                  kind == CalendarBandKind.start ||
                      kind == CalendarBandKind.pill,
                  kind == CalendarBandKind.end || kind == CalendarBandKind.pill,
                ),
              ),
          },
      ];

  /// The tiles, drawn on first use.
  static final CalendarTiles instance = CalendarTiles._();

  /// [ringHands] rings round a chosen day ([calendarCell] square).
  final List<InkDocument> rings;

  /// [ringHands] marker washes under a chosen day.
  final List<InkDocument> washes;

  /// [underlineHands] underlines for today ([calendarCell] × 10).
  final List<InkDocument> underlines;

  /// The pencil hatch over a disabled day ([hatchSize] square).
  final InkDocument hatch;

  /// The focus loop ([focusTileSize] square).
  final InkDocument focus;

  /// [bandFrames] sets of band cells ([calendarCell] × 28), by kind.
  final List<Map<CalendarBandKind, InkDocument>> bands;

  static const String _prefix = 'url("data:image/svg+xml,';

  static InkDocument _parse(String url) {
    final svg = Uri.decodeFull(url.substring(_prefix.length, url.length - 2));
    return InkDocument.parse(
      svg.substring(svg.indexOf('>') + 1, svg.lastIndexOf('</svg>')),
    );
  }

  /// Paints [document] (a [tile]-sized drawing) stretched over [rect] as a
  /// mask for [color], upstream's `mask-size: 100% 100%`; [mirror] flips
  /// it, like `scale: -1 1`.
  static void mask(
    Canvas canvas,
    LooseleafThemeData theme,
    InkDocument document,
    Size tile,
    Rect rect,
    Color color, {
    bool mirror = false,
  }) {
    if (rect.isEmpty || color.a <= 0) return;
    canvas
      ..saveLayer(rect.inflate(1), Paint())
      ..save()
      ..translate(rect.left, rect.top);
    if (mirror) {
      canvas
        ..translate(rect.width, 0)
        ..scale(-1, 1);
    }
    canvas.scale(rect.width / tile.width, rect.height / tile.height);
    InkPainter(document, InkPaintContext(theme: theme)).paintLayer(
      canvas,
      'rest',
    );
    canvas
      ..restore()
      ..drawRect(
        rect.inflate(1),
        Paint()
          ..color = color
          ..blendMode = BlendMode.srcIn,
      )
      ..restore();
  }
}
