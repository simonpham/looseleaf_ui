import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

int _frame(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(Skeleton),
      matching: find.byType(CustomPaint),
    ),
  );
  return (paint.painter as SkeletonPainter).frame.value;
}

void main() {
  test('every boil frame parses its four tiles', () {
    expect(SkeletonFrame.all, hasLength(3));
    for (final frame in SkeletonFrame.all) {
      for (final document in [
        frame.edgeH,
        frame.edgeV,
        frame.hatch,
        frame.circle,
      ]) {
        expect(document.layers['rest']?.children, isNotEmpty);
      }
    }
  });

  testWidgets('takes the size it is given', (tester) async {
    await tester.pumpWidget(
      componentHost(const Skeleton(width: 250, height: Spacing.d16)),
    );
    expect(tester.getSize(find.byType(Skeleton)), const Size(250, 16));
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 300, child: Skeleton(height: Spacing.d12)),
      ),
    );
    expect(tester.getSize(find.byType(Skeleton)), const Size(300, 12));
  });

  testWidgets('boils through three frames from its seed phase', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(const Skeleton(width: 40, height: 40, seed: 'a')),
    );
    final phase = hashSeed('a') % 3;
    expect(_frame(tester), phase);
    await tester.pump(const Duration(milliseconds: 370));
    expect(_frame(tester), (phase + 1) % 3);
    await tester.pump(const Duration(milliseconds: 360));
    expect(_frame(tester), (phase + 2) % 3);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('holds the first frame in calm density and reduced motion', (
    tester,
  ) async {
    for (final theme in [
      const LooseleafThemeData(density: LooseleafDensity.calm),
      const LooseleafThemeData(motion: LooseleafMotion.reduced),
    ]) {
      await tester.pumpWidget(
        componentHost(
          const Skeleton(width: 40, height: 40, seed: 'b'),
          theme: theme,
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));
      expect(_frame(tester), 0);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
