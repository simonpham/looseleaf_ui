import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';
import '../../support/paper_panel.dart';

Widget _outline(String label, {ButtonSize size = ButtonSize.regular}) => Button(
  variant: ButtonVariant.outline,
  size: size,
  seed: '$label-${size.id}',
  onPressed: () {},
  child: Text(label),
);

Widget _icon(String name, {ButtonSize size = ButtonSize.icon}) => Button(
  variant: ButtonVariant.outline,
  size: size,
  seed: '$name-${size.id}',
  semanticLabel: name,
  onPressed: () {},
  child: InkIcon(name, seed: name),
);

Widget _groups() => SizedBox(
  width: 520,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d24,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d40,
        children: [
          ButtonGroup(
            children: [_outline('Years'), _outline('Months'), _outline('Days')],
          ),
          ButtonGroup(
            children: [
              _icon('chevron-left'),
              _icon('search'),
              _icon('chevron-right'),
            ],
          ),
          ButtonGroup(
            orientation: SeparatorOrientation.vertical,
            children: [_icon('plus'), _icon('minus')],
          ),
        ],
      ),
      ButtonGroup(
        children: [
          const ButtonGroupText(seed: 'host', child: Text('https://')),
          const Expanded(
            child: Input(seed: 'host-input', placeholder: 'example.com'),
          ),
          Button(seed: 'go', onPressed: () {}, child: const Text('Go')),
        ],
      ),
      ButtonGroup(
        children: [
          Button(
            variant: ButtonVariant.secondary,
            seed: 'copy',
            leading: const InkIcon('copy', seed: 'copy'),
            onPressed: () {},
            child: const Text('Copy'),
          ),
          const ButtonGroupSeparator(seed: 'sep'),
          Button(
            variant: ButtonVariant.secondary,
            seed: 'paste',
            onPressed: () {},
            child: const Text('Paste'),
          ),
        ],
      ),
      ButtonGroup(
        children: [
          Button(seed: 'save', onPressed: () {}, child: const Text('Save')),
          const ButtonGroupSeparator(seed: 'sep2'),
          Button(
            seed: 'more',
            size: ButtonSize.icon,
            semanticLabel: 'More',
            onPressed: () {},
            child: const InkIcon('chevron-down', seed: 'more'),
          ),
        ],
      ),
      ButtonGroup(
        children: [
          _icon('minus'),
          const ButtonGroupText(
            seed: 'value',
            minWidth: Spacing.d56,
            alignment: MainAxisAlignment.center,
            child: Text('250'),
          ),
          _icon('plus'),
          const ButtonGroupText(seed: 'unit', child: Text('grams')),
        ],
      ),
      for (final (size, icon) in [
        (ButtonSize.xs, ButtonSize.iconXs),
        (ButtonSize.sm, ButtonSize.iconSm),
        (ButtonSize.lg, ButtonSize.iconLg),
      ])
        ButtonGroup(
          children: [
            _outline(size.id, size: size),
            _outline('Button', size: size),
            _outline('Group', size: size),
            _icon('plus', size: icon),
          ],
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

  testWidgets('button_group-layouts in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1300, 1300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(overlayHost(paperPanel(_groups())));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/button_group-layouts.png'),
    );
  });
}
