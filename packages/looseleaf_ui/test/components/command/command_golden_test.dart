import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const Key _shot = Key('shot');

Widget _desk(Widget child) => RepaintBoundary(
  key: _shot,
  child: ColoredBox(
    color: const LooseleafThemeData().colors.desk,
    child: Overlay(
      initialEntries: [
        OverlayEntry(builder: (context) => Center(child: child)),
      ],
    ),
  ),
);

Future<void> _shotOf(
  WidgetTester tester,
  Size size,
  Widget child, {
  bool settle = true,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_desk(child)));
  if (!settle) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return;
  }
  await tester.pumpAndSettle();
}

CommandItem _row(
  String icon,
  String label, {
  String? shortcut,
  bool disabled = false,
}) => CommandItem(
  disabled: disabled,
  leading: InkIcon(icon),
  trailing: switch (shortcut) {
    final keys? => CommandShortcut(keys),
    null => null,
  },
  child: Text(label),
);

List<Widget> _demo() => [
  const CommandInput(placeholder: 'Type a command or search...', seed: 'in'),
  CommandList(
    children: [
      const CommandEmpty(child: Text('No results found.')),
      CommandGroup(
        heading: const Text('Suggestions'),
        children: [
          _row('calendar', 'Calendar'),
          _row('face-slightly-smiling', 'Search Emoji'),
          _row('calculator', 'Calculator', disabled: true),
        ],
      ),
      const CommandSeparator(seed: 'rule'),
      CommandGroup(
        heading: const Text('Settings'),
        children: [
          _row('user', 'Profile', shortcut: 'Ctrl P'),
          _row('credit-card', 'Billing', shortcut: 'Ctrl B'),
          _row('settings', 'Settings', shortcut: 'Ctrl S'),
        ],
      ),
    ],
  ),
];

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('command-default in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(480, 440),
      SizedBox(
        width: 352,
        child: Command(seed: 'palette', children: _demo()),
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/command-default.png'),
    );
  });

  testWidgets('command-status in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(760, 330),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d24,
        children: [
          SizedBox(
            width: 340,
            child: Command(
              seed: 'empty',
              children: [
                const CommandInput(value: 'zzz', seed: 'in-a'),
                CommandList(
                  children: [
                    const CommandEmpty(child: Text('No documents found.')),
                    CommandGroup(
                      children: [_row('file-text', 'Invoice 0142')],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 340,
            child: Command(
              seed: 'loading',
              shouldFilter: false,
              children: [
                CommandInput(value: 'inv', seed: 'in-b'),
                CommandList(
                  children: [CommandLoading(child: Text('Searching...'))],
                ),
              ],
            ),
          ),
        ],
      ),
      settle: false,
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/command-status.png'),
    );
  });

  testWidgets('command-dialog in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(640, 520),
      CommandDialog(defaultOpen: true, seed: 'napkin', children: _demo()),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/command-dialog.png'),
    );
  });
}
