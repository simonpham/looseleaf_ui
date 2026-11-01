import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

InkArt _art(WidgetTester tester) => tester.widget<InkArt>(find.byType(InkArt));

void main() {
  test('every catalog sticker draws', () {
    for (final MapEntry(key: name, value: def) in stickers.entries) {
      expect(renderSticker(def, 96, name).svg, isNotEmpty, reason: name);
    }
  });

  testWidgets('the seeded tilt stays within the tilt budget', (tester) async {
    await tester.pumpWidget(componentHost(const Sticker('done')));
    final degrees = Sticker.autoTilt('done').clamp(-2.0, 2.0);
    expect(_art(tester).rotation, closeTo(degrees * math.pi / 180, 1e-9));
    await tester.pumpWidget(
      componentHost(
        const Sticker('done'),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(_art(tester).rotation, 0);
    await tester.pumpWidget(componentHost(const Sticker('done', rotate: 10)));
    expect(_art(tester).rotation, closeTo(10 * math.pi / 180, 1e-9));
  });

  testWidgets('peel and border key the drawing', (tester) async {
    await tester.pumpWidget(
      componentHost(const Sticker('sale', peel: Peel(22), border: 3)),
    );
    expect(_art(tester).cacheKey, 'sticker|sale|96|22|3|sale');
    await tester.pumpWidget(
      componentHost(const Sticker('sale', peel: Peel.auto())),
    );
    expect(_art(tester).cacheKey, 'sticker|sale|96|true||sale');
    await tester.pumpWidget(componentHost(const Sticker('nothing-here')));
    expect(find.byType(InkArt), findsNothing);
  });
}
