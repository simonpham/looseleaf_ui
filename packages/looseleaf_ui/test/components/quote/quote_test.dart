import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('pads the words for the marks of each size', (tester) async {
    for (final size in QuoteSize.values) {
      await tester.pumpWidget(
        componentHost(
          QuoteText(
            size: size,
            child: const SizedBox(width: 100, height: 40),
          ),
        ),
      );
      final padding = size.padding.resolve(TextDirection.ltr);
      expect(
        tester.getSize(find.byType(QuoteText)),
        Size(100 + padding.horizontal, 40 + padding.vertical),
      );
      final params =
          (tester.widget<InkSurface>(find.byType(InkSurface)).source
                  as RecipeInkSource<QuoteParams>)
              .params;
      expect(params.size, size.markSize);
    }
  });

  testWidgets('sets the words in the script face, the source muted', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Quote(
          children: [
            QuoteText(child: Text('Write it down.')),
            QuoteAttribution(child: Text('Ada')),
          ],
        ),
      ),
    );
    const theme = LooseleafThemeData();
    final words = tester.widget<RichText>(
      find.descendant(
        of: find.text('Write it down.'),
        matching: find.byType(RichText),
      ),
    );
    expect(words.text.style?.fontSize, 26 * KevinSansFace.script.sizeAdjust);
    expect(words.text.style?.color, theme.colors.ink);
    final source = tester.widget<RichText>(
      find.descendant(of: find.text('Ada'), matching: find.byType(RichText)),
    );
    expect(source.text.style?.color, theme.colors.inkMuted);
    expect(find.text('— '), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Ada')).dx -
          tester.getTopLeft(find.byType(Quote)).dx,
      greaterThan(52),
    );
  });

  testWidgets('show false leaves the marks out', (tester) async {
    await tester.pumpWidget(
      componentHost(const QuoteText(show: false, child: Text('words'))),
    );
    expect(find.byType(InkSurface), findsNothing);
  });
}
