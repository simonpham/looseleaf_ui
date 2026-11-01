import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

const _icons = {
  AlertTone.neutral: 'info',
  AlertTone.destructive: 'circle-alert',
  AlertTone.info: 'info',
  AlertTone.success: 'circle-check',
  AlertTone.warning: 'triangle-alert',
};

Widget _tones() => SizedBox(
  width: 576,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d20,
    children: [
      for (final MapEntry(key: tone, value: icon) in _icons.entries)
        Alert(
          variant: tone,
          seed: tone.id,
          icon: InkIcon(icon, seed: tone.id),
          children: [
            AlertTitle(Text('The ${tone.id} alert')),
            const AlertDescription(
              Text('You can add components to your app using the cli.'),
            ),
          ],
        ),
      Alert(
        variant: AlertTone.destructive,
        seed: 'list',
        icon: const InkIcon('circle-alert', seed: 'list'),
        children: [
          const AlertTitle(Text('Unable to process your payment.')),
          AlertDescription.children([
            const Text('Please verify your billing information and try again.'),
            Button(
              size: ButtonSize.sm,
              variant: ButtonVariant.outline,
              seed: 'update',
              onPressed: () {},
              child: const Text('Update card'),
            ),
          ]),
        ],
      ),
      const Alert(
        variant: AlertTone.info,
        seed: 'bare',
        children: [
          AlertDescription(
            Text('No icon and no title: just the box, the rule and one line.'),
          ),
        ],
      ),
      const SizedBox(
        width: 320,
        child: Alert(
          variant: AlertTone.note,
          seed: 'note',
          children: [
            AlertTitle(Text('Reminder')),
            AlertDescription(
              Text(
                'Bring the good pens. The desk is mint now, so nothing will '
                'match.',
              ),
            ),
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

  testWidgets('alert-tones in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(componentHost(paperPanel(_tones())));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/alert-tones.png'),
    );
  });
}
