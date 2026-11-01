import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('writes the name in script at each size', (tester) async {
    const theme = LooseleafThemeData();
    for (final size in SignatureSize.values) {
      await tester.pumpWidget(
        componentHost(Signature(size: size, child: const Text('Ada'))),
      );
      final name = tester.widget<RichText>(
        find.descendant(of: find.text('Ada'), matching: find.byType(RichText)),
      );
      expect(
        name.text.style?.fontSize,
        size.fontSize * KevinSansFace.script.sizeAdjust,
      );
      expect(name.text.style?.color, theme.colors.inkYou);
      final params =
          (tester.widget<InkSurface>(find.byType(InkSurface)).source
                  as RecipeInkSource<SignatureParams>)
              .params;
      expect(params.fs, size.fontSize);
    }
  });

  testWidgets('the ink pen writes the name in ink', (tester) async {
    await tester.pumpWidget(
      componentHost(const Signature(tone: MarkPen.ink, child: Text('Ada'))),
    );
    final name = tester.widget<RichText>(
      find.descendant(of: find.text('Ada'), matching: find.byType(RichText)),
    );
    expect(name.text.style?.color, const LooseleafThemeData().colors.ink);
  });

  testWidgets('animate writes the name, then the flourish', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Signature(
          animate: true,
          delay: Duration(milliseconds: 100),
          child: Text('Ada'),
        ),
      ),
    );
    final wipe = tester.widget<InkMarkWipe>(find.byType(InkMarkWipe));
    expect(wipe.delay, const Duration(milliseconds: 100));
    expect(wipe.duration, Signature.nameDuration);
    final flourish = tester.widget<InkMarkSurface>(
      find.byType(InkMarkSurface),
    );
    expect(flourish.delay, const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
  });
}
