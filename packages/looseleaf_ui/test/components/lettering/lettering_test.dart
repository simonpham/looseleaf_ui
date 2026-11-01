import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

TextStyle _style(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text)).style ?? const TextStyle();

void main() {
  testWidgets('prints script text with a riso pass and reads as a heading', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const Lettering('Field notes', size: LetteringSize.md),
      ),
    );
    final style = _style(tester);
    const colors = LooseleafColors();
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontSize, closeTo(48 * KevinSansFace.script.sizeAdjust, 1e-9));
    expect(style.shadows, hasLength(1));
    expect(style.shadows?.single.color, colors.marker);
    expect(style.shadows?.single.offset, const Offset(48 * 0.055, 48 * 0.045));
    expect(
      tester.getSemantics(find.byType(Lettering)),
      matchesSemantics(isHeader: true, label: 'Field notes'),
    );
    handle.dispose();
  });

  testWidgets('duotone adds a third pass, calm drops them', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Lettering('Two', duotone: LetteringTone.sky),
      ),
    );
    expect(_style(tester).shadows, hasLength(2));
    await tester.pumpWidget(
      componentHost(
        const Lettering('Two', duotone: LetteringTone.sky),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(_style(tester).shadows, isEmpty);
  });

  testWidgets('wobble writes it by hand', (tester) async {
    await tester.pumpWidget(
      componentHost(const Lettering('hand cut words', wobble: 1.6)),
    );
    expect(find.byType(Handwritten), findsOneWidget);
  });

  test('the big sizes grow from the sm breakpoint', () {
    expect(LetteringSize.hero.at(400), 72);
    expect(LetteringSize.hero.at(800), 128);
    expect(LetteringSize.lg.at(800), 60);
  });
}
