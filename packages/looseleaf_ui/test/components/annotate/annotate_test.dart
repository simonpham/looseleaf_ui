import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Future<void> _pump(WidgetTester tester, Annotate annotate) async {
  await tester.pumpWidget(componentHost(annotate));
  await tester.pump();
}

T _params<T>(WidgetTester tester) =>
    (tester.widget<InkSurface>(find.byType(InkSurface)).source
            as RecipeInkSource<T>)
        .params;

void main() {
  testWidgets('each type picks its mark', (tester) async {
    final expected = <AnnotateType, Type>{
      AnnotateType.underline: Underline,
      AnnotateType.box: Circled,
      AnnotateType.circle: Circled,
      AnnotateType.highlight: Highlight,
      AnnotateType.strikeThrough: Strike,
      AnnotateType.crossedOff: Strike,
      AnnotateType.brackets: Circled,
      AnnotateType.scribble: Scribble,
    };
    for (final MapEntry(key: type, value: widget) in expected.entries) {
      await _pump(tester, Annotate(type: type, child: const Text('note')));
      expect(find.byType(widget), findsOneWidget, reason: type.id);
    }
  });

  testWidgets('shapes and strike kinds follow the type', (tester) async {
    await _pump(
      tester,
      const Annotate(type: AnnotateType.brackets, child: Text('note')),
    );
    expect(
      _params<CircledParams>(tester).shape,
      CircledShape.brackets,
    );
    await _pump(
      tester,
      const Annotate(type: AnnotateType.crossedOff, child: Text('note')),
    );
    expect(_params<StrikeParams>(tester).kind, StrikeKind.cross);
  });

  testWidgets('a color is a pen or a tone, as the mark needs', (
    tester,
  ) async {
    await _pump(
      tester,
      const Annotate(
        type: AnnotateType.highlight,
        color: AnnotateColor.green,
        weight: MarkWeight.brush,
        child: Text('note'),
      ),
    );
    expect(_params<HighlightParams>(tester).tone, HighlightTone.green);
    expect(_params<HighlightParams>(tester).fat, HighlightWeight.heavy.fat);
    await _pump(
      tester,
      const Annotate(
        type: AnnotateType.underline,
        color: AnnotateColor.red,
        kind: UnderlineMarkKind.wavy,
        child: Text('note'),
      ),
    );
    expect(_params<UnderlineParams>(tester).tone, MarkPen.red);
    expect(_params<UnderlineParams>(tester).kind, UnderlineMarkKind.wavy);
    await _pump(
      tester,
      const Annotate(
        type: AnnotateType.circle,
        color: AnnotateColor.yellow,
        child: Text('note'),
      ),
    );
    expect(_params<CircledParams>(tester).tone, MarkPen.ink);
  });
}
