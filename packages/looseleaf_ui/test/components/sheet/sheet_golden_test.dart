import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

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

Widget _field(String label, TextEditingController controller) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d12,
    children: [
      Label(child: Text(label)),
      Input(controller: controller, seed: label),
    ],
  ),
);

Widget _page(String title, OverlaySide side, SheetBinding binding) =>
    SheetContent(
      side: side,
      binding: binding,
      width: 200,
      seed: title,
      children: [
        SheetHeader(
          children: [
            SheetTitle(Text(title)),
            SheetDescription(Text('${side.name} · ${binding.name}')),
          ],
        ),
      ],
    );

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('sheet-edit-profile in the light theme', (tester) async {
    tester.view.physicalSize = const Size(760, 480) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final name = TextEditingController(text: 'Pedro Duarte');
    final user = TextEditingController(text: '@peduarte');
    addTearDown(name.dispose);
    addTearDown(user.dispose);
    await tester.pumpWidget(
      componentHost(
        _stage(
          Center(
            child: Sheet(
              defaultOpen: true,
              content: SheetContent(
                seed: 'profile',
                children: [
                  const SheetHeader(
                    children: [
                      SheetTitle(Text('Edit profile')),
                      SheetDescription(
                        Text(
                          "Make changes to your profile here. Click save when you're done.",
                        ),
                      ),
                    ],
                  ),
                  _field('Name', name),
                  _field('Username', user),
                  SheetFooter(
                    children: [
                      Button(
                        seed: 'save',
                        onPressed: () {},
                        child: const Text('Save changes'),
                      ),
                      SheetClose(
                        builder: (context, close) => Button(
                          variant: ButtonVariant.outline,
                          seed: 'close',
                          onPressed: close,
                          child: const Text('Close'),
                        ),
                      ),
                    ],
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
      matchesGoldenFile('../goldens/sheet-edit-profile.png'),
    );
  });

  testWidgets('sheet-bindings in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1080, 560) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    Widget box(Widget child) => SizedBox(width: 220, height: 220, child: child);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          Column(
            key: _shot,
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d40,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d40,
                children: [
                  box(
                    Align(
                      alignment: Alignment.centerRight,
                      child: _page(
                        'Spiral',
                        OverlaySide.right,
                        SheetBinding.spiral,
                      ),
                    ),
                  ),
                  box(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _page(
                        'Holes',
                        OverlaySide.left,
                        SheetBinding.holes,
                      ),
                    ),
                  ),
                  box(
                    Align(
                      alignment: Alignment.centerRight,
                      child: _page(
                        'Perforated',
                        OverlaySide.right,
                        SheetBinding.perf,
                      ),
                    ),
                  ),
                  box(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _page('Torn', OverlaySide.left, SheetBinding.torn),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d40,
                children: [
                  SizedBox(
                    width: 460,
                    child: _page('Top', OverlaySide.top, SheetBinding.spiral),
                  ),
                  SizedBox(
                    width: 460,
                    child: _page(
                      'Bottom',
                      OverlaySide.bottom,
                      SheetBinding.holes,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/sheet-bindings.png'),
    );
  });
}
