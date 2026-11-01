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

  testWidgets('annotate-reading-notes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    InlineSpan mark(AnnotateType type, String text, [AnnotateColor? color]) =>
        WidgetSpanMark(
          child: Annotate(
            type: type,
            color: color,
            seed: 'reader-${type.id}',
            child: Text(text),
          ),
        );
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 420,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Most of what I remember from a book is in the ',
                  ),
                  mark(AnnotateType.circle, 'margins', AnnotateColor.red),
                  const TextSpan(text: '. The good bits get '),
                  mark(AnnotateType.highlight, 'a swipe of yellow'),
                  const TextSpan(text: ', the parts I doubt a '),
                  mark(AnnotateType.underline, 'red pencil', AnnotateColor.red),
                  const TextSpan(text: '. By the '),
                  mark(
                    AnnotateType.highlight,
                    'third reading',
                    AnnotateColor.green,
                  ),
                  const TextSpan(text: ' the book is more mine than the '),
                  mark(AnnotateType.strikeThrough, "writer's"),
                  const TextSpan(text: '. '),
                  mark(AnnotateType.box, 'boxed', AnnotateColor.blue),
                  const TextSpan(text: ', '),
                  mark(AnnotateType.brackets, 'bracketed'),
                  const TextSpan(text: ', '),
                  mark(AnnotateType.crossedOff, 'crossed off'),
                  const TextSpan(text: ' and '),
                  mark(AnnotateType.scribble, 'scribbled'),
                  const TextSpan(text: '.'),
                ],
              ),
              style: const TextStyle(height: 28 / 17 / 0.88),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/annotate-reading-notes.png'),
    );
  });
}

/// A mark set inline on the text's baseline.
class WidgetSpanMark extends WidgetSpan {
  const WidgetSpanMark({required super.child})
    : super(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
      );
}
