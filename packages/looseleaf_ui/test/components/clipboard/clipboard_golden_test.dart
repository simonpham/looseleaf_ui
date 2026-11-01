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

  testWidgets('clipboard-tones in the light theme', (tester) async {
    tester.view.physicalSize = const Size(2400, 1100);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final theme = const LooseleafThemeData();
    final hand = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 17,
      cssLineHeight: 28 / 17,
    );
    final title = theme.typography.face(
      KevinSansFace.script,
      cssSize: 28,
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
    );
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: theme.colors.desk,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d40),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d40,
                children: [
                  SizedBox(
                    width: 384,
                    child: Clipboard(
                      seed: 'pack',
                      tiltDegrees: -1.1,
                      children: [
                        ClipboardPaper(
                          seed: 'pack-p',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Packing list', style: title),
                              for (final (i, item) in const [
                                'Passport, tickets',
                                'Waterproof notebook',
                                'Two rolls of washi',
                                'Tea (a lot)',
                              ].indexed)
                                SizedBox(
                                  height: Spacing.d28,
                                  child: Checkbox(
                                    value: i < 2,
                                    onChanged: (_) {},
                                    seed: item,
                                    label: Text(item, style: hand),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final (i, (tone, items)) in const [
                    (null, ['milk', 'eggs', 'tea']),
                    (Accent.teal, ['rent', 'post', 'call']),
                    (Accent.tomato, ['jam', 'figs', 'rye']),
                  ].indexed)
                    SizedBox(
                      width: 192,
                      child: Clipboard(
                        tone: tone,
                        seed: tone?.name ?? 'hardboard',
                        tiltDegrees: switch (i % 2) {
                          1 => 1,
                          _ => -1,
                        },
                        minHeight: 288,
                        children: [
                          ClipboardPaper(
                            seed: '${tone?.name}-p',
                            minHeight: 160,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              Spacing.d48,
                              Spacing.d36 * 2,
                              Spacing.d12,
                              Spacing.d20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final item in items)
                                  Text(item, style: hand),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/clipboard-tones.png'),
    );
  });
}
