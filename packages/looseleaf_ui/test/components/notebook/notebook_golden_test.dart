import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _desk(double width, Widget child) => RepaintBoundary(
  child: ColoredBox(
    color: const LooseleafThemeData().colors.desk,
    child: Padding(
      padding: const EdgeInsets.all(Spacing.d40),
      child: SizedBox(width: width, child: child),
    ),
  ),
);

Future<void> _pump(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(child));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('notebook-field-notes in the light theme', (tester) async {
    await _pump(
      tester,
      const Size(560, 520),
      _desk(
        448,
        const Notebook(
          seed: 'field-notes',
          minHeight: 384,
          curl: true,
          children: [
            NotebookPage(
              children: [
                NotebookTitle(Text('Field notes')),
                Text('Tuesday. Rain on the window,'),
                Text('three cups of tea, and one'),
                Text('very small plan for a very big week.'),
                SizedBox(height: Spacing.d28),
                Text('1. ink the outline'),
                Text('2. wash the sky, then wait'),
                Text('3. hatch the shade'),
              ],
            ),
            NotebookTurn(to: 'next'),
          ],
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/notebook-field-notes.png'),
    );
  });

  testWidgets('notebook-bindings in the light theme', (tester) async {
    Widget book(
      String title,
      String line, {
      NotebookBinding binding = NotebookBinding.spiral,
      NotebookSide side = NotebookSide.start,
      int pages = 2,
      Accent? tone,
    }) => SizedBox(
      width: 340,
      child: Notebook(
        binding: binding,
        side: side,
        pages: pages,
        tone: tone,
        seed: title,
        minHeight: 256,
        children: [
          NotebookPage(children: [NotebookTitle(Text(title)), Text(line)]),
        ],
      ),
    );
    await _pump(
      tester,
      const Size(860, 720),
      _desk(
        760,
        Wrap(
          spacing: Spacing.d40,
          runSpacing: Spacing.d48,
          children: [
            book('Spiral', 'a coil for every hole'),
            book(
              'Rings',
              'rings on a steel strip',
              binding: NotebookBinding.rings,
              pages: 3,
            ),
            book(
              'Stitched',
              'a running thread',
              binding: NotebookBinding.stitched,
              pages: 1,
              tone: Accent.tomato,
            ),
            book(
              'Reporter pad',
              'call the printer before ten',
              side: NotebookSide.top,
              tone: Accent.sky,
            ),
          ],
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/notebook-bindings.png'),
    );
  });

  testWidgets('notebook-covers in the light theme', (tester) async {
    const shelf = [
      (Accent.tomato, 'Field notes', true),
      (Accent.teal, 'Recipes', true),
      (Accent.sky, 'Sketches', true),
      (Accent.grape, 'Letters', false),
      (null, 'Accounts', true),
    ];
    await _pump(
      tester,
      const Size(1100, 360),
      _desk(
        1000,
        Wrap(
          spacing: Spacing.d24,
          children: [
            for (final (tone, name, band) in shelf)
              NotebookCover(
                tone: tone,
                band: band,
                seed: name,
                child: NotebookCoverLabel(Text(name), seed: name),
              ),
          ],
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/notebook-covers.png'),
    );
  });
}
