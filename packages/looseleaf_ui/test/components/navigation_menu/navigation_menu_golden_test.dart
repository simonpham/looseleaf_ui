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

Future<void> _shotOf(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_stage(child)));
  await tester.pumpAndSettle();
}

class _Row extends StatelessWidget {
  const _Row(this.title, this.line);

  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return NavigationMenuLink(
      onPressed: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d4,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            line,
            maxLines: 2,
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              cssLineHeight: 1.375,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

NavigationMenuContent _gettingStarted() => NavigationMenuContent(
  width: 500,
  child: Builder(
    builder: (context) {
      final theme = LooseleafTheme.of(context);
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d8,
          children: [
            Expanded(
              flex: 3,
              child: NavigationMenuLink(
                onPressed: () {},
                child: Paper(
                  stock: StockName.card,
                  tilt: false,
                  seed: 'feature',
                  padding: const EdgeInsets.all(Spacing.d16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d4,
                    children: [
                      const Mascot(pose: 'wave', size: 64, seed: 'm'),
                      Text(
                        'Looseleaf',
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 24,
                          cssLineHeight: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Beautifully designed components, drawn by hand.',
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 14,
                          cssLineHeight: 1.375,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 4,
              child: Column(
                spacing: Spacing.d8,
                children: [
                  _Row(
                    'Introduction',
                    'Re-usable components built with Radix UI and Tailwind CSS.',
                  ),
                  _Row(
                    'Installation',
                    'How to install dependencies and structure your app.',
                  ),
                  _Row(
                    'Typography',
                    'Styles for headings, paragraphs, lists and more.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ),
);

Widget _demo({String? open}) => NavigationMenu(
  defaultValue: open,
  seed: 'viewport',
  semanticLabel: 'Main',
  child: NavigationMenuList(
    seed: 'line',
    children: [
      NavigationMenuItem(
        value: 'gs',
        content: _gettingStarted(),
        child: const NavigationMenuTrigger(
          seed: 'gs',
          child: Text('Getting started'),
        ),
      ),
      const NavigationMenuItem(
        value: 'cm',
        content: NavigationMenuContent(
          width: 400,
          child: _Row('Hover Card', 'For sighted users to preview content.'),
        ),
        child: NavigationMenuTrigger(seed: 'cm', child: Text('Components')),
      ),
      NavigationMenuItem(
        child: NavigationMenuLink(
          seed: 'docs',
          onPressed: () {},
          child: const Text('Docs'),
        ),
      ),
      const NavigationMenuIndicator(seed: 'u'),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('navigation-menu-strip in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(640, 400),
      Align(alignment: const Alignment(0, -0.1), child: _demo()),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/navigation-menu-strip.png'),
    );
  });

  testWidgets('navigation-menu-open in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(640, 400),
      Align(
        alignment: const Alignment(-0.6, -0.85),
        child: _demo(open: 'gs'),
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/navigation-menu-open.png'),
    );
  });

  testWidgets('navigation-menu-tabs in the light theme', (tester) async {
    const pages = ['Overview', 'Notebooks', 'Stickers', 'Settings'];
    await _shotOf(
      tester,
      const Size(640, 400),
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: Spacing.d32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d40,
            children: [
              NavigationMenu(
                child: NavigationMenuList(
                  seed: 'pages',
                  children: [
                    for (final page in pages)
                      NavigationMenuItem(
                        child: NavigationMenuLink(
                          seed: page,
                          active: page == 'Notebooks',
                          onPressed: () {},
                          child: Text(page),
                        ),
                      ),
                  ],
                ),
              ),
              const NavigationMenu(
                child: NavigationMenuList(
                  seed: 'states',
                  children: [
                    NavigationMenuItem(
                      child: NavigationMenuTrigger(
                        seed: 'r',
                        child: Text('Rest'),
                      ),
                    ),
                    NavigationMenuItem(
                      child: NavigationMenuTrigger(
                        seed: 'h',
                        forcedStates: {InkState.hovered},
                        child: Text('Hover'),
                      ),
                    ),
                    NavigationMenuItem(
                      child: NavigationMenuTrigger(
                        seed: 'f',
                        forcedStates: {InkState.focused},
                        child: Text('Focus'),
                      ),
                    ),
                    NavigationMenuItem(
                      child: NavigationMenuTrigger(
                        seed: 'd',
                        disabled: true,
                        child: Text('Disabled'),
                      ),
                    ),
                  ],
                ),
              ),
              NavigationMenu(
                viewport: false,
                defaultValue: 'product',
                child: NavigationMenuList(
                  seed: 'company',
                  children: [
                    NavigationMenuItem(
                      value: 'product',
                      content: NavigationMenuContent(
                        width: 192,
                        seed: 'own',
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Spacing.d4,
                          children: [
                            for (final link in ['Notebooks', 'Stickers'])
                              NavigationMenuLink(
                                onPressed: () {},
                                child: Row(
                                  spacing: Spacing.d8,
                                  children: [
                                    const InkIcon('chevron-right'),
                                    Text(link),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      child: const NavigationMenuTrigger(
                        seed: 'product',
                        child: Text('Product'),
                      ),
                    ),
                    const NavigationMenuItem(
                      value: 'company',
                      content: NavigationMenuContent(child: Text('About')),
                      child: NavigationMenuTrigger(
                        seed: 'company',
                        child: Text('Company'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/navigation-menu-tabs.png'),
    );
  });
}
