import 'dart:math' as math;
import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints a sheet's printed rules: ruled lines with a red margin, an index
/// card's header line, pad and ledger lines, the graph grid, the dot grid
/// or a photo's window, multiplied onto the paper and, unless calm, fading
/// a little along the line like a real print.
///
/// The Flutter side of `rulesLayer` (`src/lib/ink/paper/stocks.ts`): the
/// same geometry ([ink.ruleGeometry]) and colours as its CSS gradients.
abstract final class PaperRulesPainter {
  static const List<double> _driftStops = [0, 0.19, 0.47, 0.71, 1];
  static const List<double> _driftAlphas = [0.86, 1, 0.8, 0.96, 0.84];

  /// Paints [kind] rules over [area]. [offset] is `--ll-rule-offset` (how far
  /// rules sit above the text baseline), the geometry's by default; [first]
  /// moves the first line; [mirror] flips them for right-to-left pages.
  static void paint(
    Canvas canvas,
    Rect area,
    ink.RuleName kind, {
    required LooseleafThemeData theme,
    bool calm = false,
    double? first,
    double? offset,
    bool mirror = false,
  }) {
    if (area.isEmpty) return;
    if (kind == ink.RuleName.none || kind == ink.RuleName.ruledHand) return;
    final geo = ink.ruleGeometry(kind, calm: calm, first: first);
    final drift = !calm && kind != ink.RuleName.dots;
    canvas
      ..save()
      ..clipRect(area)
      ..saveLayer(area, Paint()..blendMode = theme.blendMode)
      ..translate(area.left, area.top);
    if (mirror) {
      canvas
        ..translate(area.width, 0)
        ..scale(-1, 1);
    }
    final size = area.size;
    final colors = theme.colors;
    switch (kind) {
      case ink.RuleName.ruled || ink.RuleName.pad || ink.RuleName.indexCard:
        _lined(canvas, size, geo, colors, offset ?? geo.offset);
      case ink.RuleName.ledger:
        _ledger(canvas, size, geo, colors, offset ?? geo.offset);
      case ink.RuleName.graph:
        _graph(canvas, size, colors);
      case ink.RuleName.dots:
        _dots(canvas, size, colors);
      case ink.RuleName.window:
        _window(canvas, size, theme);
      case ink.RuleName.none || ink.RuleName.ruledHand:
        break;
    }
    if (drift && kind != ink.RuleName.window) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = Gradient.linear(
            Offset.zero,
            Offset(size.width, 0),
            [
              for (final alpha in _driftAlphas) Color.fromRGBO(0, 0, 0, alpha),
            ],
            _driftStops,
          ),
      );
    }
    canvas
      ..restore()
      ..restore();
  }

  static Color _soft(Color color, int percent) =>
      color.withValues(alpha: color.a * percent / 100);

  static void _hlines(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double bottom,
    required double pitch,
    required double thickness,
    required double top,
  }) {
    var y = bottom - (((bottom - top) / pitch).floor() + 1) * pitch;
    for (; y <= size.height + pitch; y += pitch) {
      final from = math.max(top, y - thickness);
      final to = math.min(size.height, y);
      if (to <= from) continue;
      canvas.drawRect(Rect.fromLTRB(0, from, size.width, to), paint);
    }
  }

  static void _vline(Canvas canvas, Size size, double x, double w, Paint p) =>
      canvas.drawRect(Rect.fromLTRB(x - w / 2, 0, x + w / 2, size.height), p);

  static void _lined(
    Canvas canvas,
    Size size,
    ink.RuleGeometry geo,
    LooseleafColors colors,
    double offset,
  ) {
    final isPad = geo.kind == ink.RuleName.pad;
    final isIndex = geo.kind == ink.RuleName.indexCard;
    final rule = switch (isPad) {
      true => colors.padRule,
      false => _soft(colors.ruleBlue, 82),
    };
    final red = Paint()..color = _soft(colors.ruleRed, 88);
    final blueFirst = switch (isIndex) {
      true => geo.first + geo.pitch,
      false => geo.first,
    };
    final padTop = math.max(0.0, switch (isIndex) {
      true => geo.first + 2,
      false => blueFirst - 1,
    });
    _hlines(
      canvas,
      size,
      Paint()..color = rule,
      bottom: blueFirst + 1 - offset,
      pitch: geo.pitch,
      thickness: 0.9,
      top: math.max(0, padTop - offset),
    );
    if (isIndex) {
      final y = geo.first + 1 - offset;
      canvas.drawRect(Rect.fromLTRB(0, y - 1.2, size.width, y), red);
    }
    if (geo.margin case final margin?) _vline(canvas, size, margin, 1.2, red);
  }

  static void _ledger(
    Canvas canvas,
    Size size,
    ink.RuleGeometry geo,
    LooseleafColors colors,
    double offset,
  ) {
    final strong = Paint()..color = colors.checkRule;
    _hlines(
      canvas,
      size,
      Paint()..color = _soft(colors.checkRule, 62),
      bottom: 41 - offset,
      pitch: geo.pitch,
      thickness: 0.9,
      top: math.max(0, 40 - offset),
    );
    final head = 40 - offset;
    canvas.drawRect(Rect.fromLTRB(0, head - 1.1, size.width, head), strong);
    final (quantity, total) = geo.cols ?? (0.0, 0.0);
    _vline(canvas, size, quantity, 1, strong);
    _vline(canvas, size, size.width - total, 1, strong);
  }

  static void _grid(Canvas canvas, Size size, double pitch, Paint paint) {
    for (var y = 0.0; y < size.height; y += pitch) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
    for (var x = 0.0; x < size.width; x += pitch) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), paint);
    }
  }

  static void _graph(Canvas canvas, Size size, LooseleafColors colors) {
    _grid(canvas, size, 16, Paint()..color = _soft(colors.checkRule, 46));
    _grid(canvas, size, 64, Paint()..color = _soft(colors.checkRule, 72));
  }

  static void _dotGrid(
    Canvas canvas,
    Size size,
    double pitch,
    double start,
    double radius,
    Paint paint,
  ) {
    for (var y = start; y <= size.height + radius; y += pitch) {
      for (var x = start; x <= size.width + radius; x += pitch) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  static void _dots(Canvas canvas, Size size, LooseleafColors colors) {
    _dotGrid(
      canvas,
      size,
      20,
      0,
      0.95,
      Paint()..color = _soft(colors.pencilMark, 90),
    );
    _dotGrid(
      canvas,
      size,
      100,
      60,
      1.25,
      Paint()..color = _soft(colors.pencil, 70),
    );
  }

  static void _window(Canvas canvas, Size size, LooseleafThemeData theme) {
    final colors = theme.colors;
    final hole = Rect.fromLTRB(10, 10, size.width - 10, size.height * 0.74);
    if (hole.isEmpty) return;
    final k = theme.shadowK;
    canvas
      ..drawRect(hole, Paint()..color = _soft(colors.paperShade, 55))
      ..save()
      ..clipRect(hole)
      ..drawRect(
        hole.shift(const Offset(0, -2)).inflate(4).deflate(4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
          ..color = colors.shade.withValues(alpha: (0.26 * k).clamp(0.0, 1.0)),
      )
      ..restore()
      ..drawRect(
        hole.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = colors.shade.withValues(alpha: (0.1 * k).clamp(0.0, 1.0)),
      );
  }
}
