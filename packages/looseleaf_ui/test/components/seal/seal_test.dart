import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

InkArt _art(WidgetTester tester) => tester.widget<InkArt>(find.byType(InkArt));

void main() {
  testWidgets('every variant draws at about its size', (tester) async {
    for (final variant in SealVariant.values) {
      await tester.pumpWidget(
        componentHost(Seal(variant: variant, text: 'Top', size: 96)),
      );
      final size = tester.getSize(find.byType(InkArt));
      expect(size.width, greaterThanOrEqualTo(64), reason: variant.name);
      expect(size.width, lessThanOrEqualTo(160), reason: variant.name);
    }
  });

  testWidgets('is never smaller than 16', (tester) async {
    await tester.pumpWidget(
      componentHost(const Seal(mark: SealMark.check, size: 8)),
    );
    expect(_art(tester).cacheKey, contains('|16|'));
  });

  testWidgets('is named by its words, its mark or its variant', (
    tester,
  ) async {
    expect(const Seal(text: 'Best', sub: 'seller').description, 'Best, seller');
    expect(const Seal(text: 'Pro').description, 'Pro');
    expect(const Seal(mark: SealMark.check).description, 'Verified');
    expect(const Seal(mark: SealMark.star).description, 'Award');
    expect(
      const Seal(variant: SealVariant.wax).description,
      'wax seal',
    );
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const Seal(mark: SealMark.check, semanticLabel: 'Identity verified'),
      ),
    );
    expect(
      tester.getSemantics(find.byType(Seal)),
      matchesSemantics(label: 'Identity verified', isImage: true),
    );
    await tester.pumpWidget(
      componentHost(const Seal(mark: SealMark.check, decorative: true)),
    );
    expect(_art(tester).semanticLabel, isNull);
    handle.dispose();
  });

  testWidgets('a number tilt is used as given, auto is seeded and clamped', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const Seal(text: 'M', tilt: 8)));
    expect(_art(tester).rotation, closeTo(8 * math.pi / 180, 1e-9));
    await tester.pumpWidget(
      componentHost(const Seal(text: 'M', autoTilt: true, seed: 'x')),
    );
    final expected = Seal.seededTilt('x').clamp(-3.2, 3.2) * math.pi / 180;
    expect(_art(tester).rotation, closeTo(expected, 1e-9));
    await tester.pumpWidget(
      componentHost(
        const Seal(text: 'M', autoTilt: true, seed: 'x'),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(_art(tester).rotation, 0);
  });

  testWidgets('the drop shadow can be turned off', (tester) async {
    await tester.pumpWidget(componentHost(const Seal(text: 'A')));
    expect(_art(tester).shadow, isTrue);
    await tester.pumpWidget(
      componentHost(const Seal(text: 'A', shadow: false)),
    );
    expect(_art(tester).shadow, isFalse);
  });
}
