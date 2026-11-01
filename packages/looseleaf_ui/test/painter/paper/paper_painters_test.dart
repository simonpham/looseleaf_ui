import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

Picture record(void Function(Canvas canvas) draw) {
  final recorder = PictureRecorder();
  draw(Canvas(recorder));
  return recorder.endRecording();
}

void main() {
  const theme = LooseleafThemeData();

  test('stock colours come from the theme tokens', () {
    expect(
      PaperFacePainter.stockColor(StockName.stickyYellow, theme.colors),
      theme.colors.stickyYellow,
    );
    expect(
      PaperFacePainter.stockColor(StockName.indexCard, theme.colors),
      theme.colors.card,
    );
    final parchment = PaperFacePainter.stockColor(
      StockName.parchment,
      theme.colors,
    );
    expect(parchment, isNot(theme.colors.paper));
    expect(parchment, isNot(theme.colors.kraft));
  });

  test('shadow layers drop the contact layer unless asked for all', () {
    expect(PaperShadowPainter.layersOf(SheetShadowKind.paper), hasLength(3));
    expect(
      PaperShadowPainter.layersOf(SheetShadowKind.paper, all: false),
      hasLength(2),
    );
    expect(
      PaperShadowPainter.layersOf(SheetShadowKind.hair, all: false),
      isEmpty,
    );
  });

  test('every rule kind paints without throwing', () {
    for (final kind in RuleName.values) {
      for (final calm in [false, true]) {
        record(
          (canvas) => PaperRulesPainter.paint(
            canvas,
            const Rect.fromLTWH(0, 0, 200, 140),
            kind,
            theme: theme,
            calm: calm,
          ),
        ).dispose();
      }
    }
  });

  test('faces paint for every stock', () {
    for (final stock in StockName.values) {
      record(
        (canvas) => PaperFacePainter.paint(
          canvas,
          Path()..addRect(const Rect.fromLTWH(0, 0, 80, 50)),
          stock: stock,
          seed: 'face',
          theme: theme,
        ),
      ).dispose();
    }
  });
}
