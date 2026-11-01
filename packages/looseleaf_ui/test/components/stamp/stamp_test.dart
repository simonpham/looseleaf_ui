import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('a preset gives the words, props override it', (tester) async {
    await tester.pumpWidget(componentHost(const Stamp(name: 'stamp-paid')));
    final preset = const Stamp(name: 'stamp-paid').preset;
    expect(preset, isNotNull);
    final size = tester.getSize(find.byType(InkArt));
    expect(size.width, preset?.opts.w ?? 160);
    await tester.pumpWidget(
      componentHost(const Stamp(name: 'stamp-paid', size: 80)),
    );
    expect(tester.getSize(find.byType(InkArt)), const Size.square(80));
  });

  testWidgets('nothing to stamp shows nothing', (tester) async {
    await tester.pumpWidget(componentHost(const Stamp()));
    expect(find.byType(InkArt), findsNothing);
    await tester.pumpWidget(componentHost(const Stamp(name: 'done')));
    expect(find.byType(InkArt), findsNothing);
  });

  testWidgets('is an image named by its words', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const Stamp(text: 'Void')));
    expect(
      tester.getSemantics(find.byType(Stamp)),
      matchesSemantics(label: 'Void', isImage: true),
    );
    await tester.pumpWidget(
      componentHost(const Stamp(text: 'Void', semanticLabel: 'Cancelled')),
    );
    expect(find.bySemanticsLabel('Cancelled'), findsOneWidget);
    handle.dispose();
  });
}
