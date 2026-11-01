import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('quote-sizes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1100, 1300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 480,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d24,
              children: [
                const Quote(
                  children: [
                    QuoteText(
                      seed: 'default',
                      child: Text(
                        'The best time to write it down was when it '
                        'happened; the second best is now, before the '
                        'coffee gets cold.',
                      ),
                    ),
                    QuoteAttribution(
                      child: Text('Ada, in the margin of a book'),
                    ),
                  ],
                ),
                const QuoteText(
                  size: QuoteSize.sm,
                  tone: MarkPen.blue,
                  seed: 'sm',
                  child: Text('Small marks, blue pen.'),
                ),
                const QuoteText(
                  size: QuoteSize.lg,
                  tone: MarkPen.ink,
                  weight: MarkWeight.brush,
                  rule: true,
                  seed: 'lg',
                  child: Text('Large marks with a rule.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/quote-sizes.png'),
    );
  });
}
