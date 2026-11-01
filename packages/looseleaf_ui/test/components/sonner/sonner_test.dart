import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _host(ToastController controller, {bool closeButton = false}) =>
    componentHost(
      SizedBox.expand(
        child: Toaster(
          controller: controller,
          closeButton: closeButton,
          child: const SizedBox.expand(),
        ),
      ),
    );

ToastController _controller() {
  final controller = ToastController();
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  testWidgets('a toast shows, then times out', (tester) async {
    final controller = _controller();
    final sonner = Sonner(controller);
    var autoClosed = 0;
    await tester.pumpWidget(_host(controller));
    sonner(
      'Event created',
      description: 'Saturday, 10:00 am',
      onAutoClose: () => autoClosed++,
    );
    await tester.pump();
    expect(find.text('Event created'), findsOneWidget);
    expect(find.text('Saturday, 10:00 am'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 4100));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Event created'), findsNothing);
    expect(autoClosed, 1);
  });

  testWidgets('each type writes on its own paper with its icon', (
    tester,
  ) async {
    final controller = _controller();
    final sonner = Sonner(controller);
    await tester.pumpWidget(_host(controller));
    sonner.success('Saved');
    sonner.error('Failed');
    await tester.pump();
    final papers = tester.widgetList<Paper>(find.byType(Paper)).toList();
    expect(
      papers.map((paper) => paper.stock),
      containsAll([StockName.check, StockName.stickyPink]),
    );
    expect(
      tester.widgetList<InkIcon>(find.byType(InkIcon)).map((icon) => icon.name),
      containsAll(['circle-check', 'octagon-x']),
    );
    sonner.dismiss();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('hover fans the stack out and pauses the clock', (
    tester,
  ) async {
    final controller = _controller();
    final sonner = Sonner(controller);
    await tester.pumpWidget(_host(controller));
    sonner('First');
    await tester.pump();
    sonner('Second');
    await tester.pumpAndSettle();
    final tucked = tester.getRect(find.byType(ToastCard).first);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Second')));
    await tester.pumpAndSettle();
    final fanned = tester.getRect(find.byType(ToastCard).first);
    expect(fanned.top, lessThan(tucked.top - 20));
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Second'), findsOneWidget);
    await mouse.removePointer();
    sonner.dismiss();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the action runs and closes the toast', (tester) async {
    final controller = _controller();
    final sonner = Sonner(controller);
    var undone = 0;
    await tester.pumpWidget(_host(controller));
    sonner(
      'Note deleted',
      action: ToastButton(label: 'Undo', onPressed: () => undone++),
      cancel: ToastButton(label: 'Dismiss', onPressed: () {}),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(undone, 1);
    expect(find.text('Note deleted'), findsNothing);
  });

  testWidgets('the close button and a swipe throw it away', (tester) async {
    final controller = _controller();
    final sonner = Sonner(controller);
    await tester.pumpWidget(_host(controller, closeButton: true));
    sonner('Closable');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Close toast'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Closable'), findsNothing);
    var dismissed = 0;
    sonner('Swipe me', onDismiss: () => dismissed++);
    await tester.pumpAndSettle();
    await tester.drag(find.text('Swipe me'), const Offset(120, 0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(dismissed, 1);
    expect(find.text('Swipe me'), findsNothing);
  });

  testWidgets('a promise turns loading into success', (tester) async {
    final controller = _controller();
    final sonner = Sonner(controller);
    await tester.pumpWidget(_host(controller));
    sonner.promise<String>(
      Future.delayed(const Duration(seconds: 1), () => 'Ada'),
      loading: 'Saving…',
      success: (name) => 'Saved $name',
      error: (_) => 'Failed',
    );
    await tester.pump();
    expect(find.text('Saving…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Saved Ada'), findsOneWidget);
    sonner.dismiss();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('stacks at the bottom right, 24 in', (tester) async {
    final controller = _controller();
    final sonner = Sonner(controller);
    await tester.pumpWidget(_host(controller));
    sonner('Corner');
    await tester.pumpAndSettle();
    final card = tester.getRect(find.byType(ToastCard));
    expect(card.right, 800 - 24);
    expect(card.bottom, 600 - 24);
    expect(card.width, 360);
    sonner.dismiss();
    await tester.pump(const Duration(seconds: 1));
  });
}
