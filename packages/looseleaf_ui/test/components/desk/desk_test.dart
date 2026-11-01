import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _desk(double width) => Desk(
  objects: DeskObject.values,
  seed: 'd',
  child: SizedBox(width: width, height: 300),
);

void main() {
  testWidgets('sizes to its child plus padding', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Desk(
          padding: EdgeInsets.all(Spacing.d16),
          child: SizedBox(width: 100, height: 50),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Desk)), const Size(132, 82));
  });

  testWidgets('lays out every object on a wide desk', (tester) async {
    tester.view.physicalSize = const Size(1600, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(componentHost(_desk(900)));
    expect(find.byType(InkArt), findsNWidgets(7));
  });

  testWidgets('puts the objects away when narrow or calm', (tester) async {
    await tester.pumpWidget(componentHost(_desk(500)));
    expect(find.byType(InkArt), findsNothing);
    tester.view.physicalSize = const Size(1600, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        _desk(900),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(find.byType(InkArt), findsNothing);
  });

  testWidgets('the desk and its objects are decorative', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const Desk(objects: DeskObject.values, child: Text('Hi'))),
    );
    expect(find.bySemanticsLabel('Hi'), findsOneWidget);
    handle.dispose();
  });
}
