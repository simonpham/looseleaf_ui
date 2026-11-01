import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const Key _shot = Key('shot');

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('menubar-app in the light theme', (tester) async {
    tester.view.physicalSize = const Size(640, 400) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          key: _shot,
          child: Paper(
            stock: StockName.dotGrid,
            tilt: false,
            shadow: PaperShadow.none,
            seed: 'stage',
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Align(
                    alignment: const Alignment(0, -0.8),
                    child: Menubar(
                      seed: 'bar',
                      value: 'View',
                      children: [
                        const MenubarMenu(
                          value: 'File',
                          trigger: MenubarTrigger(child: Text('File')),
                          content: MenubarContent(children: []),
                        ),
                        const MenubarMenu(
                          value: 'Edit',
                          trigger: MenubarTrigger(child: Text('Edit')),
                          content: MenubarContent(children: []),
                        ),
                        MenubarMenu(
                          value: 'View',
                          trigger: const MenubarTrigger(child: Text('View')),
                          content: MenubarContent(
                            seed: 'view',
                            children: [
                              MenubarCheckboxItem(
                                value: false,
                                onChanged: (_) {},
                                child: const Text('Always Show Bookmarks Bar'),
                              ),
                              MenubarCheckboxItem(
                                value: true,
                                onChanged: (_) {},
                                child: const Text('Always Show Full URLs'),
                              ),
                              const MenubarSeparator(),
                              const MenubarItem(
                                inset: true,
                                trailing: MenubarShortcut('⌘R'),
                                child: Text('Reload'),
                              ),
                              const MenubarItem(
                                inset: true,
                                disabled: true,
                                trailing: MenubarShortcut('⇧⌘R'),
                                child: Text('Force Reload'),
                              ),
                              const MenubarSeparator(),
                              const MenubarItem(
                                inset: true,
                                child: Text('Toggle Fullscreen'),
                              ),
                              const MenubarSeparator(),
                              const MenubarItem(
                                inset: true,
                                child: Text('Hide Sidebar'),
                              ),
                            ],
                          ),
                        ),
                        const MenubarMenu(
                          value: 'Profiles',
                          trigger: MenubarTrigger(child: Text('Profiles')),
                          content: MenubarContent(children: []),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/menubar-app.png'),
    );
  });
}
