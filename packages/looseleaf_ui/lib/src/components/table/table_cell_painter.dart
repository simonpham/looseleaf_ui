import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/table/table_tile_documents.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Which section a table row is in: it decides the rule under the row.
enum TableSection { header, body, footer }

/// Paints one table cell's decoration, the `::after` rule and the
/// `::before` highlighter band of upstream's table stylesheet
/// (`src/components/ui/table.tsx`).
///
/// The rule is the pencil row rule (the double ink rule in a header, and
/// over a footer), offset per row and column so neighbours do not repeat,
/// faded in at the reading start of a row and out at its end. The band is
/// the highlighter behind a hovered or selected body row, with rounded
/// caps at the row's ends.
class TableCellPainter extends CustomPainter {
  TableCellPainter({
    required this.theme,
    required this.section,
    required this.row,
    required this.column,
    required this.first,
    required this.last,
    required this.rule,
    required this.direction,
    required this.band,
  }) : super(repaint: band);

  final LooseleafThemeData theme;
  final TableSection section;

  /// The row's index in its section, from 0.
  final int row;

  /// The cell's index in its row, from 0.
  final int column;
  final bool first;
  final bool last;

  /// Whether this cell draws a rule (not in a body's last row, nor in a
  /// footer but over its first row).
  final bool rule;
  final TextDirection direction;

  /// The band's opacity: 0, 0.4 hovered or expanded, 1 selected.
  final ValueNotifier<double> band;

  static const List<double> _rowShift = [0, -330, -610, -140];
  static const List<double> _columnShift = [0, -173, -419, -71, -617];
  static const double _fadeStart = 14;
  static const double _fadeEnd = 26;
  static const double _bandInset = 5;
  static const double _bandReach = 4;
  static const double _capSolid = 15;
  static const double _capHeight = 40;

  bool get _calm => theme.density == LooseleafDensity.calm;

  @override
  void paint(Canvas canvas, Size size) {
    _band(canvas, size);
    if (rule) _rule(canvas, size);
  }

  void _band(Canvas canvas, Size size) {
    final opacity = band.value;
    if (section != TableSection.body || opacity <= 0) return;
    final color = theme.colors.hiSelect;
    final paint = Paint()..color = color.withValues(alpha: color.a * opacity);
    final ltr = direction == TextDirection.ltr;
    final leftEdge = (first && ltr) || (last && !ltr);
    final rightEdge = (last && ltr) || (first && !ltr);
    if (_calm) {
      canvas.drawRect(
        Rect.fromLTRB(0, 2, size.width, size.height - 2),
        paint..isAntiAlias = false,
      );
      return;
    }
    final box = Rect.fromLTRB(
      switch (leftEdge) {
        true => -_bandReach,
        false => 0,
      },
      _bandInset,
      size.width +
          switch (rightEdge) {
            true => _bandReach,
            false => 0,
          },
      size.height - _bandInset,
    );
    if (box.isEmpty) return;
    final tiles = TableTileDocuments.instance;
    canvas.saveLayer(box.inflate(1), Paint());
    final black = Paint()
      ..color = const Color(0xFF000000)
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromLTRB(
        box.left +
            switch (leftEdge) {
              true => _capSolid,
              false => 0,
            },
        box.top,
        box.right -
            switch (rightEdge) {
              true => _capSolid,
              false => 0,
            },
        box.bottom,
      ),
      black,
    );
    if (leftEdge) {
      _stretch(
        canvas,
        tiles.capStart,
        Rect.fromLTWH(box.left, box.top, tableCapW, box.height),
        const Size(tableCapW, _capHeight),
      );
    }
    if (rightEdge) {
      _stretch(
        canvas,
        tiles.capEnd,
        Rect.fromLTWH(box.right - tableCapW, box.top, tableCapW, box.height),
        const Size(tableCapW, _capHeight),
      );
    }
    canvas
      ..drawRect(
        box,
        paint
          ..blendMode = BlendMode.srcIn
          ..isAntiAlias = false,
      )
      ..restore();
  }

  void _rule(Canvas canvas, Size size) {
    final colors = theme.colors;
    final double height;
    final double top;
    final Color color;
    final bool flip;
    switch (section) {
      case TableSection.header:
        height = tableHeadH;
        top = size.height + 6 - height;
        color = colors.inkSoft;
        flip = false;
      case TableSection.footer:
        height = tableHeadH;
        top = -6;
        color = colors.inkSoft;
        flip = true;
      case TableSection.body:
        height = tableRuleH;
        top = size.height + 4 - height;
        color = colors.pencilMark;
        flip = false;
    }
    if (_calm) {
      _calmRule(canvas, size);
      return;
    }
    final box = Rect.fromLTWH(0, top, size.width, height);
    canvas.saveLayer(box.inflate(1), Paint());
    final document = switch (section) {
      TableSection.body => TableTileDocuments.instance.rule,
      _ => TableTileDocuments.instance.head,
    };
    final shift =
        _rowShift[row % _rowShift.length] +
        _columnShift[column % _columnShift.length];
    var x = shift % tableTileW;
    if (x > 0) x -= tableTileW;
    canvas
      ..save()
      ..clipRect(box);
    if (flip) {
      canvas
        ..translate(0, box.top + box.bottom)
        ..scale(1, -1);
    }
    for (; x < size.width; x += tableTileW) {
      _stretch(
        canvas,
        document,
        Rect.fromLTWH(x, top, tableTileW, height),
        Size(tableTileW, height),
      );
    }
    canvas
      ..restore()
      ..drawRect(
        box,
        Paint()
          ..color = color
          ..blendMode = BlendMode.srcIn,
      );
    _fade(canvas, box);
    canvas.restore();
  }

  void _calmRule(Canvas canvas, Size size) {
    final colors = theme.colors;
    final header = section != TableSection.body;
    final height = switch (header) {
      true => 2.0,
      false => 1.0,
    };
    final top = switch (section) {
      TableSection.header => size.height + 1 - height,
      TableSection.footer => -1.0,
      TableSection.body => size.height - height,
    };
    final color = switch (header) {
      true => colors.inkSoft,
      false => colors.lineSoft.withValues(alpha: colors.lineSoft.a * 0.7),
    };
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, height),
      Paint()..color = color,
    );
  }

  /// The `--ll-fade-s` / `--ll-fade-e` gradients at a row's ends.
  void _fade(Canvas canvas, Rect box) {
    if (!first && !last) return;
    final ltr = direction == TextDirection.ltr;
    final w = box.width;
    if (w <= 0) return;
    final stops = <double>[];
    final alphas = <double>[];
    void stop(double at, double alpha) {
      stops.add((at / w).clamp(0, 1));
      alphas.add(alpha);
    }

    if (first) {
      stop(0, 0);
      stop(_fadeStart, 1);
    } else {
      stop(0, 1);
    }
    if (last) {
      stop(w - _fadeEnd, 1);
      stop(w, 0);
    } else {
      stop(w, 1);
    }
    final from = switch (ltr) {
      true => box.centerLeft,
      false => box.centerRight,
    };
    final to = switch (ltr) {
      true => box.centerRight,
      false => box.centerLeft,
    };
    canvas.drawRect(
      box,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = LinearGradient(
          colors: [for (final alpha in alphas) Color.fromRGBO(0, 0, 0, alpha)],
          stops: stops,
        ).createShader(Rect.fromPoints(from, to)),
    );
  }

  void _stretch(Canvas canvas, InkDocument document, Rect rect, Size tile) {
    canvas
      ..save()
      ..translate(rect.left, rect.top)
      ..scale(rect.width / tile.width, rect.height / tile.height);
    InkPainter(
      document,
      InkPaintContext(theme: theme),
    ).paintLayer(canvas, 'rest');
    canvas.restore();
  }

  @override
  bool shouldRepaint(TableCellPainter oldDelegate) =>
      oldDelegate.theme != theme ||
      oldDelegate.section != section ||
      oldDelegate.row != row ||
      oldDelegate.column != column ||
      oldDelegate.first != first ||
      oldDelegate.last != last ||
      oldDelegate.rule != rule ||
      oldDelegate.direction != direction ||
      oldDelegate.band != band;
}
