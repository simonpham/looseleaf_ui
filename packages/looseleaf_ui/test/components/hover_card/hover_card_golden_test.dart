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

Widget _card({
  required String link,
  required String caption,
  required String line,
  required Widget art,
  required String seed,
  OverlaySide side = OverlaySide.bottom,
  OverlayAlign align = OverlayAlign.center,
  PaperTape? tape,
  double? tiltDegrees,
  double width = HoverCardContent.defaultWidth,
}) => HoverCard(
  defaultOpen: true,
  content: HoverCardContent(
    seed: seed,
    side: side,
    align: align,
    tape: tape,
    tiltDegrees: tiltDegrees,
    width: width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HoverCardMedia(seed: '$seed-media', child: art),
        HoverCardCaption(Text(caption)),
        Builder(
          builder: (context) {
            final theme = LooseleafTheme.of(context);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
              child: Text(
                line,
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 14,
                  cssLineHeight: 20 / 14,
                  color: theme.colors.inkMuted,
                ),
              ),
            );
          },
        ),
      ],
    ),
  ),
  child: Button(
    variant: ButtonVariant.link,
    onPressed: () {},
    seed: link,
    child: Text(link),
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

  testWidgets('hover-card-profile in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(720, 360),
      Stack(
        children: [
          Align(
            alignment: const Alignment(-0.6, -0.85),
            child: _card(
              link: '@looseleaf',
              caption: '@looseleaf',
              line: 'shadcn/ui, drawn by hand. Joined September 2026.',
              art: const Doodle('flower', size: 88, seed: 'flower'),
              seed: 'profile',
            ),
          ),
          Align(
            alignment: const Alignment(0.6, -0.85),
            child: _card(
              link: 'Looseleaf 1.0',
              caption: 'v1.0 is out',
              line: 'Forty-odd components, every line drawn by hand.',
              art: const Sticker('rocket', size: 84, seed: 'rocket'),
              seed: 'release',
              tape: PaperTape.top,
              tiltDegrees: -1.2,
              width: 288,
            ),
          ),
        ],
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/hover-card-profile.png'),
    );
  });

  testWidgets('hover-card-sides in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(900, 340),
      Stack(
        children: [
          Align(
            alignment: const Alignment(-0.35, -0.8),
            child: _card(
              link: 'Instant, left',
              caption: 'Instant, left',
              line: 'open 0 ms, close 100 ms',
              art: const Doodle('sun', size: 72, seed: 'sun'),
              seed: 'left',
              side: OverlaySide.left,
              align: OverlayAlign.start,
              width: 224,
            ),
          ),
          Align(
            alignment: const Alignment(0.35, -0.8),
            child: _card(
              link: 'Patient, right',
              caption: 'Patient, right',
              line: 'open 1200 ms, close 300 ms',
              art: const Doodle('star', size: 72, seed: 'star'),
              seed: 'right',
              side: OverlaySide.right,
              align: OverlayAlign.start,
              width: 224,
            ),
          ),
        ],
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/hover-card-sides.png'),
    );
  });
}
