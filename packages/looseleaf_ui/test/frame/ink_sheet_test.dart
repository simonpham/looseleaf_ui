import 'dart:ui';


import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() {
  InkMarkup sheetMarkup(SheetParams params) => RecipeInkSource(
    sheetRecipe,
    params,
    json: params.toJson(),
  ).draw(const InkFrameRequest(box: Size(160, 100), seed: 'sheet'));

  test('a plain frame has no sheet', () {
    expect(InkSheet.of(['rest'], {'rest': '<path d="M0 0L1 1"/>'}), isNull);
  });

  test('a torn sheet splits into ink, a face and ink, with a cast', () {
    final markup = sheetMarkup(
      const SheetParams(
        stock: StockName.paper,
        edge: EdgeSpec.all(EdgeKind.torn),
      ),
    );
    final sheet = InkSheet.of(['rest'], markup.parts);
    expect(sheet, isNotNull);
    final pieces = sheet?.pieces ?? const [];
    expect(pieces.whereType<InkSheetFace>(), hasLength(1));
    expect(pieces.last, isA<InkSheetRun>());
    expect(sheet?.casts.single.cast?.kind, SheetShadowKind.paper);
    final face = pieces.whereType<InkSheetFace>().single;
    expect(face.layer, 'rest');
    expect(face.path.getBounds().width, greaterThan(150));
  });

  test('runs share ids across one document', () {
    final markup = sheetMarkup(
      const SheetParams(
        stock: StockName.paper,
        edge: EdgeSpec.all(EdgeKind.zig),
      ),
    );
    final sheet = InkSheet.of(['rest'], markup.parts);
    final runs = sheet?.pieces.whereType<InkSheetRun>().toList() ?? [];
    final parts = {for (final run in runs) ...run.groups.map((g) => g.$2)};
    expect(sheet?.document.layers.keys.toSet(), parts);
    expect(sheet?.document.elements.keys, isNotEmpty);
  });

  test('the frame cache keeps the sheet on the frame', () {
    const params = SheetParams(
      stock: StockName.kraft,
      edge: EdgeSpec.all(EdgeKind.deckle),
    );
    final frame = InkFrameCache().frame(
      RecipeInkSource(sheetRecipe, params, json: params.toJson()),
      const InkFrameRequest(box: Size(120, 80), seed: 'k'),
    );
    expect(frame.sheet, isNotNull);
    expect(frame.has('rest'), isTrue);
  });
}
