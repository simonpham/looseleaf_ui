import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const _defaults = [
  'check',
  'x',
  'plus',
  'minus',
  'search',
  'chevron-down',
  'arrow-right',
  'copy',
  'trash',
  'pencil',
  'user',
  'settings',
  'calendar',
  'ellipsis',
];

const _toned = [
  'triangle-alert',
  'info',
  'bell',
  'search',
  'user',
  'calendar',
  'circle-check',
];

Widget _row(List<Widget> children) => Row(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.end,
  spacing: Spacing.d20,
  children: children,
);

Widget _overview() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d24,
  children: [
    _row([for (final name in _defaults) InkIcon(name)]),
    for (final name in ['check', 'search', 'triangle-alert', 'settings'])
      _row([
        for (final size in [12.0, 16.0, 20.0, 24.0, 32.0, 48.0])
          InkIcon(name, size: size),
      ]),
    _row([for (final name in _toned) InkIcon(name, size: 32)]),
    _row([
      for (final name in _toned) InkIcon(name, size: 32, tone: ArtTone.doodle),
    ]),
    _row([
      for (final accent in ArtAccent.values.take(7))
        InkIcon('bell', size: 32, tone: ArtTone.doodle, accent: accent),
    ]),
    _row(const [
      InkIcon('LucideArrowRight', size: 24),
      InkIcon('arrow-right', size: 24, flip: IconFlip.x),
      InkIcon('no-such-icon', size: 24),
    ]),
  ],
);

Widget _catalog() => SizedBox(
  width: 1100,
  child: Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    children: [for (final name in icons.keys) InkIcon(name, size: 24)],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  for (final (name, build) in [
    ('icon-overview', _overview),
    ('icon-catalog', _catalog),
  ]) {
    testWidgets('$name in the light theme', (tester) async {
      tester.view.physicalSize = const Size(2400, 1400);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(componentHost(goldenPanel(build())));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('../goldens/$name.png'),
      );
    });
  }
}
