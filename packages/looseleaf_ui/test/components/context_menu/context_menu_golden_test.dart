import 'package:flutter/gestures.dart';
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

  testWidgets('context-menu-page in the light theme', (tester) async {
    tester.view.physicalSize = const Size(720, 520) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    const theme = LooseleafThemeData();
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          key: _shot,
          child: ColoredBox(
            color: theme.colors.desk,
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Align(
                    alignment: const Alignment(-0.5, -0.6),
                    child: ContextMenu(
                      content: ContextMenuContent(
                        width: 288,
                        seed: 'ctx',
                        children: [
                          const ContextMenuItem(
                            inset: true,
                            trailing: ContextMenuShortcut('⌘['),
                            child: Text('Back'),
                          ),
                          const ContextMenuItem(
                            inset: true,
                            disabled: true,
                            trailing: ContextMenuShortcut('⌘]'),
                            child: Text('Forward'),
                          ),
                          const ContextMenuItem(
                            inset: true,
                            trailing: ContextMenuShortcut('⌘R'),
                            child: Text('Reload'),
                          ),
                          const ContextMenuSub(
                            trigger: ContextMenuSubTrigger(
                              inset: true,
                              child: Text('More tools'),
                            ),
                            content: ContextMenuSubContent(
                              children: [ContextMenuItem(child: Text('Save page as…'))],
                            ),
                          ),
                          const ContextMenuSeparator(),
                          ContextMenuCheckboxItem(
                            value: true,
                            onChanged: (_) {},
                            child: const Text('Show bookmarks'),
                          ),
                          ContextMenuCheckboxItem(
                            value: false,
                            onChanged: (_) {},
                            child: const Text('Show full URLs'),
                          ),
                          const ContextMenuSeparator(),
                          const ContextMenuLabel(
                            inset: true,
                            child: Text('People'),
                          ),
                          ContextMenuRadioGroup(
                            value: 'pedro',
                            onChanged: (_) {},
                            children: const [
                              ContextMenuRadioItem(
                                value: 'pedro',
                                child: Text('Pedro Duarte'),
                              ),
                              ContextMenuRadioItem(
                                value: 'colm',
                                child: Text('Colm Tuite'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      child: ContextMenuTrigger(
                        child: Paper(
                          stock: StockName.graph,
                          seed: 'region',
                          child: SizedBox(
                            width: 320,
                            height: 176,
                            child: Center(
                              child: Text(
                                'Right-click anywhere',
                                style: theme.typography.face(
                                  KevinSansFace.script,
                                  cssSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
    await tester.tapAt(
      tester.getCenter(find.text('Right-click anywhere')),
      buttons: kSecondaryButton,
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/context-menu-page.png'),
    );
  });
}
