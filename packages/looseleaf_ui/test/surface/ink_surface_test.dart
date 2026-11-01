import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../support/fixture_frames.dart';
import '../support/fixture_source.dart';

Widget _host(InkSource source, Set<InkState> states, InkFrameCache cache) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          child: SizedBox(
            width: 152,
            height: 72,
            child: Center(
              child: InkSurface(
                source: source,
                seed: 'surface',
                states: states,
                cache: cache,
                child: const SizedBox(width: 120, height: 40),
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  final frame = FixtureFrame.named('button-outline');

  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(
      InkTextures.instance.load,
    );
  });

  testWidgets('draws lazy layers once a state needs them', (tester) async {
    final cache = InkFrameCache();
    final source = FixtureSource(frame, lazyLayers: {'focus', 'pressed'});
    await tester.pumpWidget(_host(source, const {}, cache));
    expect(source.requests, hasLength(1));
    expect(source.requests.single.box, const Size(120, 40));
    await tester.pumpWidget(_host(source, const {InkState.focused}, cache));
    await tester.pumpAndSettle();
    expect(source.requests.last.lazyOnly, isTrue);
    expect(source.requests.last.lazy, {'focus'});
  });

  testWidgets('shows the hover layer, tilted, once hovered', (tester) async {
    final cache = InkFrameCache();
    final source = FixtureSource(frame, lazyLayers: {'focus', 'pressed'});
    await tester.pumpWidget(_host(source, const {}, cache));
    await tester.pumpWidget(_host(source, const {InkState.hovered}, cache));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/surface-hovered.png'),
    );
  });

  testWidgets('pressed sinks the rest layer and hides hover', (tester) async {
    final cache = InkFrameCache();
    final source = FixtureSource(frame, lazyLayers: {'focus', 'pressed'});
    await tester.pumpWidget(_host(source, const {InkState.hovered}, cache));
    await tester.pumpWidget(
      _host(source, const {InkState.hovered, InkState.pressed}, cache),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/surface-pressed.png'),
    );
  });

  testWidgets('animates layer opacity with the CSS durations', (tester) async {
    final cache = InkFrameCache();
    final source = FixtureSource(frame);
    await tester.pumpWidget(_host(source, const {}, cache));
    await tester.pumpWidget(_host(source, const {InkState.hovered}, cache));
    await tester.pump(const Duration(milliseconds: 75));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('reduced motion jumps straight to the new state', (tester) async {
    final cache = InkFrameCache();
    final source = FixtureSource(frame);
    Widget themed(Set<InkState> states) => LooseleafTheme(
      data: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      child: _host(source, states, cache),
    );
    await tester.pumpWidget(themed(const {}));
    await tester.pumpWidget(themed(const {InkState.hovered}));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
