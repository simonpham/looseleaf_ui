import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('sizes follow the variant', (tester) async {
    await tester.pumpWidget(componentHost(const TypingIndicator()));
    expect(tester.getSize(find.byType(TypingIndicator)), const Size(56, 24));
    await tester.pumpWidget(
      componentHost(const TypingIndicator(variant: TypingVariant.squiggle)),
    );
    expect(tester.getSize(find.byType(TypingIndicator)), const Size(80, 24));
  });

  testWidgets('is a live region labelled while active', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const TypingIndicator(label: 'Ana is typing')),
    );
    expect(
      tester.getSemantics(find.byType(TypingIndicator)),
      matchesSemantics(label: 'Ana is typing', isLiveRegion: true),
    );
    await tester.pumpWidget(
      componentHost(const TypingIndicator(active: false)),
    );
    expect(find.byType(InkSurface), findsNothing);
    handle.dispose();
  });

  testWidgets('dots paint one copy per dot plus the pencil', (tester) async {
    await tester.pumpWidget(componentHost(const TypingIndicator(seed: 't')));
    expect(find.byType(InkSurface), findsNWidgets(4));
    await tester.pumpWidget(
      componentHost(const TypingIndicator(seed: 't', pencil: false)),
    );
    expect(find.byType(InkSurface), findsNWidgets(3));
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface).first).source
                as RecipeInkSource<TypingParams>)
            .params;
    expect(params.pencil, isFalse);
  });

  testWidgets('dots pop in turn', (tester) async {
    await tester.pumpWidget(componentHost(const TypingIndicator(seed: 't')));
    List<double> opacities() => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(TypingIndicator),
            matching: find.byType(Opacity),
          ),
        )
        .map((o) => o.opacity)
        .toList();
    await tester.pump(const Duration(milliseconds: 500));
    expect(opacities(), [1, 0, 0]);
    await tester.pump(const Duration(milliseconds: 400));
    expect(opacities(), [1, 1, 0]);
  });

  test('keyframes match the CSS', () {
    expect(TypingIndicatorMotion.dot(0), (0, 0.3));
    expect(TypingIndicatorMotion.dot(0.2), (1, 1.3));
    expect(TypingIndicatorMotion.dot(0.5), (1, 1));
    expect(TypingIndicatorMotion.hop(0.05), -1);
    expect(TypingIndicatorMotion.hop(0.35), -0.5);
    expect(TypingIndicatorMotion.hop(0.6), 0);
    expect(TypingIndicatorMotion.wipe(0.9), 1);
    expect(TypingIndicatorMotion.walk(0), -1);
  });

  testWidgets('reduced motion keeps the marks still and whole', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const TypingIndicator(seed: 't'),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final opacities = tester
        .widgetList<Opacity>(find.byType(Opacity))
        .map((o) => o.opacity);
    expect(opacities, everyElement(1));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
