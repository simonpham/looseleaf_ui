import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

void main() {
  testWidgets('tapping the label focuses its field', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      overlayHost(
        SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Label(focusNode: focusNode, child: const Text('Email')),
              Input(focusNode: focusNode),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Email'));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('onPressed runs on tap', (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      overlayHost(Label(onPressed: () => presses++, child: const Text('Go'))),
    );
    await tester.tap(find.text('Go'));
    expect(presses, 1);
  });

  testWidgets('a disabled label ignores taps and turns graphite', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      overlayHost(
        Label(
          disabled: true,
          onPressed: () => presses++,
          child: const Text('Off'),
        ),
      ),
    );
    await tester.tap(find.text('Off'));
    expect(presses, 0);
    final style = DefaultTextStyle.of(tester.element(find.text('Off'))).style;
    expect(style.color, const LooseleafColors().pencilText);
  });

  testWidgets('required draws a decorative star', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      overlayHost(const Label(required: true, child: Text('Name'))),
    );
    expect(find.byType(LabelRequiredMark), findsOneWidget);
    expect(find.bySemanticsLabel('Name'), findsOneWidget);
    expect(
      tester.getSize(find.byType(LabelRequiredMark)),
      const Size.square(Spacing.d12),
    );
    handle.dispose();
  });

  testWidgets('the label is 15 px bold Kevin Sans Hand', (tester) async {
    await tester.pumpWidget(overlayHost(const Label(child: Text('Email'))));
    final style = DefaultTextStyle.of(tester.element(find.text('Email'))).style;
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontSize, closeTo(15 * 0.88, 0.001));
  });
}
