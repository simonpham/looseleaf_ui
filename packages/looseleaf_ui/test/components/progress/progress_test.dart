import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Rect _window(WidgetTester tester) {
  final clip = tester.widget<ClipRect>(
    find.descendant(of: find.byType(Progress), matching: find.byType(ClipRect)),
  );
  final size = tester.getSize(find.byType(Progress));
  return (clip.clipper as ProgressClipper?)?.getClip(size) ?? Rect.zero;
}

Widget _bar(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    SizedBox(
      width: 200,
      child: Directionality(textDirection: direction, child: child),
    );

void main() {
  testWidgets('fills up to the value, from the reading start', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_bar(const Progress(value: 45))));
    await tester.pumpAndSettle();
    expect(
      _window(tester),
      rectMoreOrLessEquals(const Rect.fromLTRB(0, -12, 90, 28)),
    );
    await tester.pumpWidget(
      componentHost(
        _bar(const Progress(value: 45), direction: TextDirection.rtl),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      _window(tester),
      rectMoreOrLessEquals(const Rect.fromLTRB(110, -12, 200, 28)),
    );
  });

  testWidgets('clamps to max and glides between values', (tester) async {
    await tester.pumpWidget(
      componentHost(_bar(const Progress(value: 30, max: 60))),
    );
    await tester.pumpAndSettle();
    expect(_window(tester).right, 100);
    await tester.pumpWidget(
      componentHost(_bar(const Progress(value: 90, max: 60))),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(_window(tester).right, inExclusiveRange(100, 200));
    await tester.pumpAndSettle();
    expect(_window(tester).right, 200);
  });

  testWidgets('sizes are 12, 16 and 20 tall', (tester) async {
    for (final size in ProgressSize.values) {
      await tester.pumpWidget(
        componentHost(_bar(Progress(value: 10, size: size))),
      );
      expect(tester.getSize(find.byType(Progress)).height, size.height);
    }
  });

  testWidgets('indeterminate slides a scribble window across', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_bar(const Progress())));
    final fill = tester.widgetList<InkSurface>(find.byType(InkSurface)).last;
    expect(fill.source.paramsKey, contains('"indeterminate":true'));
    expect(_window(tester).left, -80);
    await tester.pump(const Duration(milliseconds: 800));
    expect(_window(tester).left, closeTo(60, 1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('indeterminate rests mid-bar with reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        _bar(const Progress()),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
    expect(_window(tester).left, 60);
    expect(_window(tester).right, 140);
  });

  testWidgets('reads its label and value to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(_bar(const Progress(value: 45, semanticLabel: 'Upload'))),
    );
    final data = tester.getSemantics(find.byType(Progress)).getSemanticsData();
    expect(data.label, 'Upload');
    expect(data.value, '45');
    await tester.pumpWidget(
      componentHost(
        _bar(const Progress(value: 2, max: 5, semanticValue: 'Step 2 of 5')),
      ),
    );
    expect(
      tester.getSemantics(find.byType(Progress)).getSemanticsData().value,
      'Step 2 of 5',
    );
    handle.dispose();
  });

  testWidgets('the fill draws with the tone and its own seed', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        _bar(const Progress(value: 50, tone: ProgressTone.blue, seed: 'p')),
      ),
    );
    final surfaces = tester.widgetList<InkSurface>(find.byType(InkSurface));
    expect(surfaces.first.seed, 'p');
    expect(surfaces.last.seed, 'p:fill');
    expect(surfaces.last.source.paramsKey, contains('"tone":"blue"'));
  });
}
