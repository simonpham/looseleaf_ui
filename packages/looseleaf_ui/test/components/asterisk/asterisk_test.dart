import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('draws the mark after the child in the tone', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Asterisk(
          mark: AsteriskMark.dagger,
          tone: AsteriskTone.blue,
          child: Text('price'),
        ),
      ),
    );
    expect(find.text('price'), findsOneWidget);
    final art = tester.widget<InkArt>(find.byType(InkArt));
    expect(art.color, const LooseleafColors().inkYou);
    expect(art.cacheKey, startsWith('asterisk|dagger|'));
    expect(art.size?.width, closeTo(0.8 * 17, 1e-9));
  });

  testWidgets('a label names the decorative mark as an image', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const Asterisk(label: 'required')),
    );
    expect(
      tester.getSemantics(find.byType(InkArt)),
      matchesSemantics(isImage: true, label: 'required'),
    );
    handle.dispose();
  });

  testWidgets('with onPressed it is a footnote link', (tester) async {
    final handle = tester.ensureSemantics();
    var pressed = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(
        Asterisk(
          focusNode: focusNode,
          onPressed: () => pressed++,
          child: const Text(r'$16'),
        ),
      ),
    );
    await tester.tap(find.byType(InkArt));
    expect(pressed, 1);
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pressed, 2);
    expect(find.bySemanticsLabel('footnote'), findsOneWidget);
    handle.dispose();
  });
}
