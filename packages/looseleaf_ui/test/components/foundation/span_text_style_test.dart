import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

TextStyle? _style(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style;

void main() {
  testWidgets('a mark in a WidgetSpan takes the Text.rich style', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Text.rich(
          style: TextStyle(fontSize: 40),
          TextSpan(
            children: [
              TextSpan(text: 'Three books for the '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Underline(child: Text('slow weeks')),
              ),
            ],
          ),
        ),
      ),
    );
    expect(_style(tester, 'slow weeks')?.fontSize, 40);
  });

  testWidgets('styles merge down the spans to the WidgetSpan', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Text.rich(
          style: TextStyle(fontSize: 30),
          TextSpan(
            children: [
              TextSpan(
                style: TextStyle(fontWeight: FontWeight.w700),
                children: [
                  WidgetSpan(
                    child: Highlight(
                      child: Text(
                        'bold',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ],
              ),
              WidgetSpan(child: Strike(child: Text('plain'))),
            ],
          ),
        ),
      ),
    );
    final bold = _style(tester, 'bold');
    expect(bold?.fontSize, 30);
    expect(bold?.fontWeight, FontWeight.w700);
    expect(bold?.fontStyle, FontStyle.italic);
    final plain = _style(tester, 'plain');
    expect(plain?.fontSize, 30);
    expect(plain?.fontWeight, isNot(FontWeight.w700));
  });

  testWidgets('outside a WidgetSpan nothing changes', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const DefaultTextStyle(
          style: TextStyle(fontSize: 12),
          child: Underline(child: Text('alone')),
        ),
      ),
    );
    expect(_style(tester, 'alone')?.fontSize, 12);
  });

  testWidgets('an asterisk in a WidgetSpan sizes to the span', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Text.rich(
          style: TextStyle(fontSize: 36),
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Asterisk(child: Text(r'$24')),
              ),
            ],
          ),
        ),
      ),
    );
    expect(_style(tester, r'$24')?.fontSize, 36);
  });
}
