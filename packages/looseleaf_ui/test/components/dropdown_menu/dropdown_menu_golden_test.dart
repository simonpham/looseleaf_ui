import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const Key _shot = Key('shot');

Widget _stage(Widget child) => RepaintBoundary(
  key: _shot,
  child: Paper(
    stock: StockName.dotGrid,
    tilt: false,
    shadow: PaperShadow.none,
    seed: 'stage',
    child: Overlay(
      initialEntries: [OverlayEntry(builder: (context) => child)],
    ),
  ),
);

Widget _trigger(String label) => DropdownMenuTrigger.builder(
  builder: (context, menu) => Button(
    variant: ButtonVariant.outline,
    onPressed: menu.toggle,
    seed: label,
    child: Text(label),
  ),
);

Future<void> _shotOf(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_stage(child)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('dropdown-menu-account in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(640, 420),
      Align(
        alignment: const Alignment(-0.6, -0.85),
        child: DropdownMenu(
          defaultOpen: true,
          content: DropdownMenuContent(
            width: 256,
            align: OverlayAlign.start,
            seed: 'account',
            children: [
              const DropdownMenuLabel(child: Text('My account')),
              DropdownMenuGroup(
                children: [
                  DropdownMenuItem(
                    leading: const InkIcon('user'),
                    trailing: const DropdownMenuShortcut('⇧⌘P'),
                    onSelect: () {},
                    child: const Text('Profile'),
                  ),
                  const DropdownMenuItem(
                    leading: InkIcon('credit-card'),
                    trailing: DropdownMenuShortcut('⌘B'),
                    child: Text('Billing'),
                  ),
                  const DropdownMenuItem(
                    leading: InkIcon('settings'),
                    trailing: DropdownMenuShortcut('⌘,'),
                    child: Text('Settings'),
                  ),
                  const DropdownMenuItem(
                    leading: InkIcon('user-plus'),
                    disabled: true,
                    child: Text('Invite users'),
                  ),
                ],
              ),
              const DropdownMenuSeparator(),
              const DropdownMenuSub(
                trigger: DropdownMenuSubTrigger(
                  leading: InkIcon('users'),
                  child: Text('Team'),
                ),
                content: DropdownMenuSubContent(
                  seed: 'team',
                  children: [
                    DropdownMenuItem(
                      leading: InkIcon('mail'),
                      child: Text('Email'),
                    ),
                    DropdownMenuItem(
                      leading: InkIcon('message-square'),
                      child: Text('Message'),
                    ),
                    DropdownMenuSeparator(),
                    DropdownMenuItem(
                      leading: InkIcon('plus'),
                      child: Text('More…'),
                    ),
                  ],
                ),
              ),
              const DropdownMenuSeparator(),
              const DropdownMenuItem(
                variant: InkMenuItemVariant.destructive,
                leading: InkIcon('log-out'),
                trailing: DropdownMenuShortcut('⇧⌘Q'),
                child: Text('Log out'),
              ),
            ],
          ),
          child: _trigger('Open'),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT, character: 't');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/dropdown-menu-account.png'),
    );
  });

  testWidgets('dropdown-menu-ticks in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(420, 420),
      Align(
        alignment: const Alignment(0, -0.85),
        child: DropdownMenu(
          defaultOpen: true,
          content: DropdownMenuContent(
            width: 224,
            seed: 'view',
            children: [
              const DropdownMenuLabel(child: Text('Appearance')),
              DropdownMenuCheckboxItem(
                value: true,
                onChanged: (_) {},
                child: const Text('Status bar'),
              ),
              const DropdownMenuCheckboxItem(
                value: false,
                disabled: true,
                child: Text('Activity bar'),
              ),
              DropdownMenuCheckboxItem(
                value: true,
                onChanged: (_) {},
                child: const Text('Panel'),
              ),
              const DropdownMenuSeparator(),
              const DropdownMenuLabel(child: Text('Panel position')),
              DropdownMenuRadioGroup(
                value: 'bottom',
                onChanged: (_) {},
                children: const [
                  DropdownMenuRadioItem(value: 'top', child: Text('Top')),
                  DropdownMenuRadioItem(value: 'bottom', child: Text('Bottom')),
                  DropdownMenuRadioItem(value: 'right', child: Text('Right')),
                ],
              ),
              const DropdownMenuSeparator(),
              const DropdownMenuItem(
                inset: true,
                variant: InkMenuItemVariant.destructive,
                child: Text('Reset layout'),
              ),
            ],
          ),
          child: _trigger('View'),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/dropdown-menu-ticks.png'),
    );
  });
}
