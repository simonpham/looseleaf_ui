import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const ButtonParams _params = ButtonParams(
  variant: ButtonVariant.primary,
  size: ButtonSize.regular,
);

RecipeInkSource<ButtonParams> _source() =>
    RecipeInkSource(buttonRecipe, _params, json: _params.toJson());

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(
      InkTextures.instance.load,
    );
  });

  test('draws what runRecipe draws', () {
    final source = _source();
    const request = InkFrameRequest(
      box: Size(96, 36),
      seed: 'adapter',
      density: LooseleafDensity.compact,
      textDirection: TextDirection.rtl,
      knobs: LooseleafKnobs(wobble: 1.2, width: 0.9),
      lazy: {'focus'},
    );
    final markup = source.draw(request);
    final frame = runRecipe(
      buttonRecipe,
      RunRequest(
        box: const Box(96, 36),
        params: _params,
        seed: 'adapter',
        tier: Tier.lo,
        density: Density.compact,
        dir: Dir.rtl,
        knobs: Knobs(wobble: 1.2, width: 0.9),
        lazy: const [LayerName.focus],
      ),
    );
    expect(markup.parts, {
      for (final MapEntry(:key, :value) in frame.parts.entries) key.name: value,
    });
    expect(markup.pad, frame.pad);
    expect(markup.parts.keys, containsAll(['rest', 'hover', 'focus']));
    expect(markup.parts.keys, isNot(contains('pressed')));
  });

  test('keys by recipe, rev and params; lazy layers come from the recipe', () {
    final source = _source();
    expect(source.id, 'button@${buttonRecipe.rev}');
    expect(source.paramsKey, '{"size":"default","variant":"default"}');
    expect(source.lazyLayers, {'focus', 'pressed'});
  });

  test('lazyOnly draws only the requested lazy layers', () {
    final markup = _source().draw(
      const InkFrameRequest(
        box: Size(96, 36),
        seed: 'adapter',
        lazy: {'pressed'},
        lazyOnly: true,
      ),
    );
    expect(markup.parts.keys, ['pressed']);
  });

  testWidgets('an InkSurface paints buttonRecipe', (tester) async {
    final cache = InkFrameCache();
    final boundary = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: boundary,
            child: SizedBox(
              width: 152,
              height: 72,
              child: Center(
                child: InkSurface(
                  source: _source(),
                  seed: 'surface',
                  cache: cache,
                  child: const SizedBox(width: 120, height: 40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(cache.length, 1);
    expect(cache.misses, 1);

    final render =
        boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (render == null) fail('no repaint boundary');
    final inked = await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData();
      image.dispose();
      return _opaquePixels(bytes);
    });
    expect(inked, greaterThan(500));
  });
}

int _opaquePixels(ByteData? bytes) {
  if (bytes == null) return 0;
  var count = 0;
  for (var i = 3; i < bytes.lengthInBytes; i += 4) {
    if (bytes.getUint8(i) > 0) count++;
  }
  return count;
}
