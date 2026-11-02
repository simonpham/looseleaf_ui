import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('is at most 448 wide with the paper inside a 24 px rim', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const InkClipboard(
          seed: 'c',
          children: [ClipboardPaper(seed: 'p', child: Text('Visitors'))],
        ),
      ),
    );
    final board = tester.getRect(find.byType(InkClipboard));
    final paper = tester.getRect(find.byType(ClipboardPaper));
    expect(board.width, 448);
    expect(paper.left - board.left, 24);
    expect(paper.top - board.top, 32);
    expect(board.bottom - paper.bottom, 24);
    expect(paper.height, 256);
    expect(
      tester.getTopLeft(find.text('Visitors')) - paper.topLeft,
      const Offset(56, 72),
    );
  });

  testWidgets('narrows to its parent', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: InkClipboard(children: [ClipboardPaper(child: Text('a'))]),
        ),
      ),
    );
    expect(tester.getSize(find.byType(InkClipboard)).width, 300);
  });

  testWidgets('the paper grows into a least height', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const InkClipboard(
          minHeight: 400,
          children: [ClipboardPaper(minHeight: 160, child: Text('jam'))],
        ),
      ),
    );
    expect(tester.getSize(find.byType(InkClipboard)).height, 400);
    expect(tester.getSize(find.byType(ClipboardPaper)).height, 400 - 56);
  });

  testWidgets('draws the clip, hidden when calm', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const InkClipboard(children: [ClipboardPaper(child: Text('a'))]),
      ),
    );
    expect(find.byType(ClipboardClip), findsOneWidget);
    await tester.pumpWidget(
      componentHost(
        const InkClipboard(children: [ClipboardPaper(child: Text('a'))]),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(find.byType(ClipboardClip), findsNothing);
  });

  testWidgets('the paper is ruled and mirrors its rules right to left', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: InkClipboard(children: [ClipboardPaper(child: Text('a'))]),
        ),
      ),
    );
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.rules, RuleName.ruled);
    expect(paper.mirrorRules, isTrue);
  });

  testWidgets('the board and the clip are decorative', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const InkClipboard(
          tone: Accent.teal,
          children: [ClipboardPaper(child: Text('Visitors'))],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Visitors')),
      matchesSemantics(label: 'Visitors'),
    );
    handle.dispose();
  });
}
