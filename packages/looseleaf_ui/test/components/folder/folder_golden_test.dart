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

  testWidgets('folder-stocks in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1640, 1640);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    const theme = LooseleafThemeData();
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          key: const ValueKey('shot'),
          child: ColoredBox(
            color: theme.colors.desk,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d40),
              child: SizedBox(
                width: 720,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d48,
                  children: [
                    Folder(
                      defaultValue: 'inbox',
                      children: [
                        const FolderTabs(
                          semanticLabel: 'Mail',
                          children: [
                            FolderTab(
                              value: 'inbox',
                              seed: 'inbox',
                              child: Text('Inbox'),
                            ),
                            FolderTab(
                              value: 'drafts',
                              seed: 'drafts',
                              forcedStates: {InkState.hovered},
                              child: Text('Drafts'),
                            ),
                            FolderTab(
                              value: 'sent',
                              seed: 'sent',
                              forcedStates: {InkState.focused},
                              child: Text('Sent'),
                            ),
                            FolderTab(
                              value: 'archive',
                              seed: 'archive',
                              disabled: true,
                              child: Text('Archive'),
                            ),
                          ],
                        ),
                        FolderContent(
                          value: 'inbox',
                          seed: 'in',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Spacing.d8,
                            children: [
                              Text(
                                'Inbox',
                                style: theme.typography.title(cssSize: 30),
                              ),
                              const Text(
                                'Three letters are waiting: one from Ada, '
                                'and a parcel notice that has been waiting '
                                'longer.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Folder(
                      stock: StockName.stickyYellow,
                      defaultValue: 'one',
                      maxWidth: 320,
                      children: [
                        FolderTabs(
                          children: [
                            FolderTab(
                              value: 'one',
                              seed: 'one',
                              child: Text('Recipes'),
                            ),
                          ],
                        ),
                        FolderContent(
                          value: 'one',
                          seed: 'y',
                          tape: PaperTape.top,
                          child: Text(
                            'A folder with one tab is just a labeled folder.',
                          ),
                        ),
                      ],
                    ),
                    const Folder(
                      stock: StockName.paper,
                      defaultValue: 'c',
                      children: [
                        FolderTabs(
                          children: [
                            FolderTab(
                              value: 'a',
                              seed: 'a',
                              child: Text('Sketches'),
                            ),
                            FolderTab(
                              value: 'b',
                              seed: 'b',
                              child: Text('Notes'),
                            ),
                            FolderTab(
                              value: 'c',
                              seed: 'c',
                              child: Text('Photos'),
                            ),
                          ],
                        ),
                        FolderContent(
                          value: 'c',
                          seed: 'c',
                          fastener: FastenerKind.clip,
                          child: Text(
                            'White card, three tabs, the last one open.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('shot')),
      matchesGoldenFile('../goldens/folder-stocks.png'),
    );
  });
}
