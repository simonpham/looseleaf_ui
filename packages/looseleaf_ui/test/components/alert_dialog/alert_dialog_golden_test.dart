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

AlertDialogContent _question({
  required String seed,
  required String icon,
  required String title,
  required String body,
  required String ok,
  AlertMediaTone media = AlertMediaTone.neutral,
  AlertDialogTone tone = AlertDialogTone.neutral,
  AlertDialogSize size = AlertDialogSize.regular,
  ButtonVariant variant = ButtonVariant.primary,
}) => AlertDialogContent(
  seed: seed,
  tone: tone,
  size: size,
  children: [
    AlertDialogHeader(
      children: [
        AlertDialogMedia(tone: media, seed: seed, child: InkIcon(icon)),
        AlertDialogTitle(Text(title)),
        AlertDialogDescription(Text(body)),
      ],
    ),
    AlertDialogFooter(
      children: [
        AlertDialogCancel(seed: '$seed-no', child: const Text('Not yet')),
        AlertDialogAction(
          seed: '$seed-ok',
          variant: variant,
          child: Text(ok),
        ),
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

  testWidgets('alert-dialog-delete in the light theme', (tester) async {
    tester.view.physicalSize = const Size(720, 400) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        _stage(
          Center(
            child: AlertDialog(
              defaultOpen: true,
              content: _question(
                seed: 'delete',
                icon: 'trash',
                title: 'Delete this notebook?',
                body: 'This will permanently delete “Field notes” and its 48 pages. You cannot undo this.',
                ok: 'Delete notebook',
                media: AlertMediaTone.danger,
                tone: AlertDialogTone.danger,
                variant: ButtonVariant.destructive,
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
      matchesGoldenFile('../goldens/alert-dialog-delete.png'),
    );
  });

  testWidgets('alert-dialog-variants in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1240, 380) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          Row(
            key: _shot,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d32,
            children: [
              SizedBox(
                width: 440,
                child: _question(
                  seed: 'publish',
                  icon: 'circle-check',
                  title: 'Publish now?',
                  body: 'Everyone with the link will be able to read it. You can unpublish later.',
                  ok: 'Publish',
                ),
              ),
              _question(
                seed: 'info',
                icon: 'info',
                title: 'Sign out everywhere?',
                body: 'You will be signed out of every device.',
                ok: 'Sign out',
                media: AlertMediaTone.info,
                size: AlertDialogSize.small,
              ),
              _question(
                seed: 'clear',
                icon: 'triangle-alert',
                title: 'Clear all history?',
                body: 'Every search and every draft will be removed.',
                ok: 'Clear it',
                media: AlertMediaTone.danger,
                tone: AlertDialogTone.danger,
                size: AlertDialogSize.small,
                variant: ButtonVariant.destructive,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/alert-dialog-variants.png'),
    );
  });
}
