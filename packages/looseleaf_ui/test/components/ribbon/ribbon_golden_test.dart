import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(List<Widget> children) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d16,
  children: children,
);

Widget _grid() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d20,
  children: [
    const Ribbon(
      size: RibbonSize.lg,
      seed: 'lg',
      child: Text('New arrivals'),
    ),
    const Ribbon(
      tone: RibbonTone.sky,
      seed: 'sky',
      child: Text('Staff pick'),
    ),
    const Ribbon(
      size: RibbonSize.sm,
      tone: RibbonTone.grass,
      seed: 'sm',
      child: Text('In stock'),
    ),
    _row(const [
      Ribbon(seed: 'banner', child: Text('Banner')),
      Ribbon(
        variant: RibbonVariant.swallow,
        tone: RibbonTone.lemon,
        seed: 'swallow',
        child: Text('Swallow'),
      ),
      Ribbon(
        variant: RibbonVariant.flag,
        tone: RibbonTone.tangerine,
        seed: 'flag',
        child: Text('Flag'),
      ),
    ]),
    _row([
      for (final tone in RibbonTone.values)
        Ribbon(
          tone: tone,
          size: RibbonSize.sm,
          seed: tone.name,
          child: Text(tone.name),
        ),
    ]),
    _row([
      for (final (name, states) in [
        ('rest', <InkState>{}),
        ('hover', {InkState.hovered}),
        ('focus', {InkState.focused}),
      ])
        Ribbon(
          tone: RibbonTone.sky,
          seed: 'link-$name',
          onPressed: () {},
          forcedStates: states,
          leading: const InkIcon('arrow-right'),
          child: Text(name),
        ),
    ]),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('ribbon-variants in the light theme', (tester) async {
    tester.view.physicalSize = const Size(2800, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(componentHost(goldenPanel(_grid())));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/ribbon-variants.png'),
    );
  });
}
