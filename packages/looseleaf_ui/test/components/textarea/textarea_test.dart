import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Set<InkState> _states(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface)).states;

Widget _host(Widget child) => overlayHost(SizedBox(width: 240, child: child));

void main() {
  testWidgets('starts at min-h-16 and grows with its lines', (tester) async {
    await tester.pumpWidget(_host(const Textarea()));
    expect(tester.getSize(find.byType(Textarea)).height, Spacing.d64);
    await tester.enterText(find.byType(EditableText), 'one\ntwo\nthree\nfour');
    await tester.pump();
    expect(
      tester.getSize(find.byType(Textarea)).height,
      Spacing.d8 * 2 + TextareaMetrics.lineHeight * 4,
    );
  });

  testWidgets('a ruled field starts at min-h-24', (tester) async {
    await tester.pumpWidget(_host(const Textarea(ruled: true)));
    expect(tester.getSize(find.byType(Textarea)).height, Spacing.d96);
  });

  testWidgets('a fixed field keeps its height', (tester) async {
    await tester.pumpWidget(_host(const Textarea(autoGrow: false)));
    await tester.enterText(find.byType(EditableText), '1\n2\n3\n4\n5\n6');
    await tester.pump();
    expect(tester.getSize(find.byType(Textarea)).height, Spacing.d64);
  });

  testWidgets('rows set the starting lines', (tester) async {
    await tester.pumpWidget(_host(const Textarea(rows: 4)));
    expect(
      tester.getSize(find.byType(Textarea)).height,
      Spacing.d8 * 2 + TextareaMetrics.lineHeight * 4,
    );
  });

  testWidgets('a single row keeps min-h-16', (tester) async {
    await tester.pumpWidget(_host(const Textarea(rows: 1)));
    expect(tester.getSize(find.byType(Textarea)).height, Spacing.d64);
  });

  testWidgets('minHeight replaces min-h-16', (tester) async {
    await tester.pumpWidget(_host(const Textarea(minHeight: Spacing.d96)));
    expect(tester.getSize(find.byType(Textarea)).height, Spacing.d96);
  });

  testWidgets('a fixed field takes minHeight as its height', (tester) async {
    await tester.pumpWidget(
      _host(const Textarea(minHeight: Spacing.d96, autoGrow: false)),
    );
    expect(tester.getSize(find.byType(Textarea)).height, Spacing.d96);
  });

  testWidgets('focus draws the focus ring', (tester) async {
    await tester.pumpWidget(_host(const Textarea()));
    await tester.tap(find.byType(Textarea));
    await tester.pump();
    expect(_states(tester), contains(InkState.focused));
  });

  testWidgets('the counter follows the text and stops at maxLength', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const Textarea(showCount: true, maxLength: 5)),
    );
    expect(find.text('0/5'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'abc');
    await tester.pump();
    expect(find.text('3/5'), findsOneWidget);
    expect(find.bySemanticsLabel('3 characters of 5'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'abcdefgh');
    await tester.pump();
    expect(find.text('5/5'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('dragging the grip resizes it', (tester) async {
    await tester.pumpWidget(_host(const Textarea()));
    final box = tester.getRect(find.byType(Textarea));
    await tester.dragFrom(
      box.bottomRight - const Offset(4, 4),
      const Offset(0, 40),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(Textarea)).height, closeTo(104, 1));
  });

  testWidgets('disabled shows its states and cannot be focused', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const Textarea(disabled: true)));
    await tester.tap(find.byType(Textarea), warnIfMissed: false);
    await tester.pump();
    expect(_states(tester), {InkState.disabled});
  });
}
