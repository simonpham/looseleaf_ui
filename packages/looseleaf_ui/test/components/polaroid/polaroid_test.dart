import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Color? _veil(WidgetTester tester) => tester
    .widget<ColoredBox>(
      find.descendant(
        of: find.byType(PolaroidVeil),
        matching: find.byType(ColoredBox),
      ),
    )
    .color;

void main() {
  testWidgets('is 256 wide, a square window and a 48 px caption', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Polaroid(
          seed: 'p',
          children: [
            PolaroidImage(scene: PolaroidScene.hills, seed: 'h'),
            PolaroidCaption(Text('august')),
          ],
        ),
      ),
    );
    final frame = tester.getRect(find.byType(Polaroid));
    final window = tester.getRect(find.byType(PolaroidImage));
    expect(frame.width, 256);
    expect(window.size, const Size(228, 228));
    expect(window.topLeft - frame.topLeft, const Offset(14, 14));
    final caption = tester.getRect(find.byType(PolaroidCaption));
    expect(caption.top - window.bottom, 10);
    expect(caption.height, 48);
    expect(frame.bottom - caption.bottom, 12);
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.stock, StockName.photo);
    expect(paper.rules, RuleName.none);
  });

  testWidgets('a scene is decoration unless labelled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const PolaroidImage(scene: PolaroidScene.sea, seed: 's')),
    );
    expect(find.bySemanticsLabel('Sea'), findsNothing);
    await tester.pumpWidget(
      componentHost(
        const PolaroidImage(scene: PolaroidScene.sea, label: 'Sea', seed: 's'),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Sea')),
      matchesSemantics(label: 'Sea', isImage: true),
    );
    handle.dispose();
  });

  testWidgets('the date stamp is decorative and sits in the end corner', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 200, child: PolaroidImage(date: "'25 8 09")),
      ),
    );
    expect(find.bySemanticsLabel("'25 8 09"), findsNothing);
    final window = tester.getRect(find.byType(PolaroidImage));
    final stamp = tester.getRect(find.byType(PolaroidDate));
    expect(window.right - stamp.right, 10);
    expect(window.bottom - stamp.bottom, 8);
    handle.dispose();
  });

  testWidgets('develop clears the veil after half a second', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 200, child: PolaroidImage(develop: true)),
      ),
    );
    expect(_veil(tester)?.a, greaterThan(0.9));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_veil(tester)?.a, greaterThan(0.9));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.descendant(
        of: find.byType(PolaroidVeil),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
  });

  testWidgets('develop is instant with reduced motion', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 200, child: PolaroidImage(develop: true)),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(PolaroidVeil),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
  });

  testWidgets('disposing mid-develop leaves no timers', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 200, child: PolaroidImage(develop: true)),
      ),
    );
    await tester.pumpWidget(componentHost(const SizedBox()));
    await tester.pump(const Duration(seconds: 2));
  });
}
