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

Widget _goal(BuildContext context) {
  final theme = LooseleafTheme.of(context);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: Spacing.d16,
    children: [
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.icon,
        seed: 'minus',
        onPressed: () {},
        child: const InkIcon('minus'),
      ),
      Column(
        children: [
          Text(
            '350',
            style: theme.typography.face(
              KevinSansFace.script,
              cssSize: 72,
              cssLineHeight: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Calories/day',
            style: theme.typography.face(
              KevinSansFace.type,
              cssSize: 11.2,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.icon,
        seed: 'plus',
        onPressed: () {},
        child: const InkIcon('plus'),
      ),
    ],
  );
}

Future<void> _shotOf(
  WidgetTester tester,
  Size size,
  OverlaySide direction,
  String golden,
) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    componentHost(
      _stage(
        Center(
          child: Drawer(
            defaultOpen: true,
            direction: direction,
            content: DrawerContent(
              seed: 'goal',
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: SheetContent.maxSideWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const DrawerHeader(
                          children: [
                            DrawerTitle(Text('Move goal')),
                            DrawerDescription(
                              Text('Set your daily activity goal.'),
                            ),
                          ],
                        ),
                        const Builder(builder: _goal),
                        DrawerFooter(
                          children: [
                            Button(
                              seed: 'submit',
                              onPressed: () {},
                              child: const Text('Submit'),
                            ),
                            DrawerClose(
                              builder: (context, close) => Button(
                                variant: ButtonVariant.outline,
                                seed: 'cancel',
                                onPressed: close,
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            child: const SizedBox(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await expectLater(
    find.byKey(_shot),
    matchesGoldenFile('../goldens/$golden.png'),
  );
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('drawer-move-goal in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(600, 560),
      OverlaySide.bottom,
      'drawer-move-goal',
    );
  });

  testWidgets('drawer-right in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(760, 460),
      OverlaySide.right,
      'drawer-right',
    );
  });
}
