import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const _faq = [
  (
    'item-1',
    'Is it accessible?',
    'Yes. It follows the WAI-ARIA accordion pattern: one tab stop per row, '
        'arrows between rows, and every panel is labeled by its trigger.',
  ),
  (
    'item-2',
    'Is it drawn by hand?',
    'Every rule, brace and highlighter swipe is a pen stroke, seeded so the '
        'same page always looks the same.',
  ),
  (
    'item-3',
    'Does it respect reduced motion?',
    'Yes. With reduced motion the rows open at once and the brace simply '
        'appears.',
  ),
];

Widget _faqAccordion({bool states = true}) => SizedBox(
  width: 448,
  child: Accordion(
    collapsible: true,
    defaultValue: const {'item-1'},
    children: [
      for (final (value, question, answer) in _faq)
        AccordionItem(
          value: value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccordionTrigger(
                seed: value,
                forcedStates: switch (states ? value : '') {
                  'item-2' => const {InkState.hovered},
                  'item-3' => const {InkState.focused},
                  _ => const {},
                },
                child: Text(question),
              ),
              AccordionContent(child: Text(answer)),
            ],
          ),
        ),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('accordion-faq in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1100, 1300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            spacing: Spacing.d32,
            children: [_faqAccordion(), _faqAccordion(states: false)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/accordion-faq.png'),
    );
  });
}
