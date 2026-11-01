import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

SpinnerPainter _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.descendant(
                of: find.byType(Spinner),
                matching: find.byType(CustomPaint),
              ),
            )
            .painter
        as SpinnerPainter;

void main() {
  testWidgets('announces Loading as a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const Spinner()));
    expect(
      tester.getSemantics(find.byType(Spinner)),
      matchesSemantics(label: 'Loading', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('sizes: a 16 square, loops four times as wide, Stubby 64', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const Spinner()));
    expect(tester.getSize(find.byType(Spinner)), const Size(16, 16));
    await tester.pumpWidget(componentHost(const Spinner(size: Spacing.d24)));
    expect(tester.getSize(find.byType(Spinner)), const Size(24, 24));
    await tester.pumpWidget(
      componentHost(const Spinner(variant: SpinnerVariant.loops)),
    );
    final loops = tester.getSize(find.byType(Spinner));
    expect(loops.width, greaterThan(64));
    expect(loops.height, lessThan(loops.width / 3));
    await tester.pumpWidget(
      componentHost(const Spinner(variant: SpinnerVariant.write, seed: 's')),
    );
    expect(tester.getSize(find.byType(Spinner)).height, lessThanOrEqualTo(64));
  });

  testWidgets('moves a dash window round the scribble', (tester) async {
    await tester.pumpWidget(componentHost(const Spinner(seed: 'a')));
    final start = _painter(tester).effects;
    expect(start.revealDashes, [0.42, 0.58]);
    await tester.pump(const Duration(milliseconds: 600));
    expect(_painter(tester).effects.reveal, closeTo(0.5, 0.01));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Stubby flips through three frames', (tester) async {
    await tester.pumpWidget(
      componentHost(const Spinner(variant: SpinnerVariant.write, seed: 'w')),
    );
    final frames = <String>{};
    for (var i = 0; i < 3; i++) {
      frames.add(tester.widget<InkArt>(find.byType(InkArt)).cacheKey);
      await tester.pump(const Duration(milliseconds: 360));
    }
    expect(frames, hasLength(3));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('holds still where motion is reduced', (tester) async {
    const reduced = LooseleafThemeData(motion: LooseleafMotion.reduced);
    await tester.pumpWidget(
      componentHost(const Spinner(seed: 'r'), theme: reduced),
    );
    expect(tester.hasRunningAnimations, isFalse);
    expect(_painter(tester).effects.revealDashes, isNull);
    expect(_painter(tester).effects.reveal, 1);
    await tester.pumpWidget(
      componentHost(
        const Spinner(variant: SpinnerVariant.write, seed: 'w'),
        theme: reduced,
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
    expect(
      tester.widget<InkArt>(find.byType(InkArt)).cacheKey,
      contains('write-3'),
    );
  });
}
