import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _example({required bool open}) => Collapsible(
  defaultOpen: open,
  child: SizedBox(
    width: 360,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          builder: (context) => Button(
            variant: ButtonVariant.link,
            seed: 'trigger-$open',
            onPressed: Collapsible.of(context).toggle,
            trailing: const CollapsibleIndicator(),
            child: const Text('What is in the box?'),
          ),
        ),
        const SizedBox(height: Spacing.d8),
        Builder(
          builder: (context) => DefaultTextStyle.merge(
            style: LooseleafTheme.of(context).typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              cssLineHeight: 20 / 14,
              color: LooseleafTheme.of(context).colors.inkMuted,
            ),
            child: const CollapsibleContent(
              bracket: BracketKind.curly,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d8,
                children: [
                  Text(
                    'One pencil stub, sharpened crooked. Three felt tips that '
                    'still work. A yellow highlighter, half dry.',
                  ),
                  Text('A ruler with a chip out of the end.'),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('collapsible-bracket in the light theme', (tester) async {
    tester.view.physicalSize = const Size(900, 500);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [_example(open: true), _example(open: false)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/collapsible-bracket.png'),
    );
  });
}
