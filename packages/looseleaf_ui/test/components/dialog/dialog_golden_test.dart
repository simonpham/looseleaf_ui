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

Widget _field(String label, TextEditingController controller) => Row(
  spacing: Spacing.d16,
  children: [
    SizedBox(
      width: 80,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Label(child: Text(label)),
      ),
    ),
    Expanded(
      child: Input(controller: controller, seed: label),
    ),
  ],
);

Widget _note(
  String title,
  String body,
  DialogContent Function(List<Widget>) content,
) => content([
  DialogHeader(
    children: [DialogTitle(Text(title)), DialogDescription(Text(body))],
  ),
  DialogFooter(
    children: [
      Button(seed: title, onPressed: () {}, child: const Text('Got it')),
    ],
  ),
]);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('dialog-edit-profile in the light theme', (tester) async {
    tester.view.physicalSize = const Size(720, 480) * 2;
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
            child: Dialog(
              defaultOpen: true,
              content: DialogContent(
                tape: PaperTape.both,
                tapeKind: TapeKind.washiDots,
                seed: 'edit-profile',
                maxWidth: 425,
                children: [
                  const DialogHeader(
                    children: [
                      DialogTitle(Text('Edit profile')),
                      DialogDescription(
                        Text(
                          "Make changes to your profile here. Click save when you're done.",
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
                    child: Column(
                      spacing: Spacing.d16,
                      children: [
                        _field('Name', name),
                        _field('Username', user),
                      ],
                    ),
                  ),
                  DialogFooter(
                    children: [
                      DialogClose(
                        builder: (context, close) => Button(
                          variant: ButtonVariant.outline,
                          seed: 'cancel',
                          onPressed: close,
                          child: const Text('Cancel'),
                        ),
                      ),
                      Button(
                        seed: 'save',
                        onPressed: () {},
                        child: const Text('Save changes'),
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
      matchesGoldenFile('../goldens/dialog-edit-profile.png'),
    );
  });

  testWidgets('dialog-paper in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1180, 360) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    Widget sized(Widget child) => SizedBox(width: 336, child: child);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          Row(
            key: _shot,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d40,
            children: [
              sized(
                _note(
                  'Handle with care',
                  'Kraft stock, one strip of clear tape across the top edge.',
                  (children) => DialogContent(
                    stock: StockName.kraft,
                    tape: PaperTape.top,
                    tapeKind: TapeKind.clear,
                    seed: 'kraft',
                    children: children,
                  ),
                ),
              ),
              sized(
                _note(
                  'Torn from a pad',
                  'A pad sheet torn top and bottom, held with a paper clip.',
                  (children) => DialogContent(
                    stock: StockName.pad,
                    edge: const EdgeSpec(
                      top: EdgeKind.torn,
                      bottom: EdgeKind.torn,
                    ),
                    fastener: FastenerKind.clip,
                    seed: 'torn',
                    children: children,
                  ),
                ),
              ),
              sized(
                _note(
                  'Sticky business',
                  'A sticky note with a push-pin through it, turned a degree and a half.',
                  (children) => DialogContent(
                    stock: StockName.stickyYellow,
                    fastener: FastenerKind.pin,
                    tiltDegrees: 1.4,
                    seed: 'sticky',
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/dialog-paper.png'),
    );
  });
}
