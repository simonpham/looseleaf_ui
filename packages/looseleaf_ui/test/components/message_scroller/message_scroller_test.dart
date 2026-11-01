import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

const double _row = 60;

Widget _chat(
  List<int> ids, {
  MessageScrollerController? controller,
  bool autoScroll = false,
  MessageScrollerPosition position = MessageScrollerPosition.end,
  Set<int> anchors = const {},
}) => componentHost(
  SizedBox(
    width: 320,
    height: 300,
    child: MessageScrollerProvider(
      controller: controller,
      autoScroll: autoScroll,
      defaultPosition: position,
      child: MessageScroller(
        children: [
          MessageScrollerViewport(
            child: MessageScrollerContent(
              children: [
                for (final id in ids)
                  MessageScrollerItem(
                    key: ValueKey(id),
                    messageId: 'm$id',
                    scrollAnchor: anchors.contains(id),
                    child: SizedBox(height: _row, child: Text('Message $id')),
                  ),
              ],
            ),
          ),
          const MessageScrollerButton(),
          const MessageScrollerButton(
            direction: MessageScrollerDirection.start,
          ),
        ],
      ),
    ),
  ),
);

List<int> _range(int from, int to) => [for (var i = from; i < to; i++) i];

ScrollPosition _position(MessageScrollerController controller) =>
    controller.scrollController.position;

double _topOf(WidgetTester tester, int id) =>
    tester.getTopLeft(find.text('Message $id')).dy -
    tester.getTopLeft(find.byType(MessageScrollerViewport)).dy;

void main() {
  late MessageScrollerController controller;

  setUp(() => controller = MessageScrollerController());
  tearDown(() => controller.dispose());

  testWidgets('opens at the newest message', (tester) async {
    await tester.pumpWidget(_chat(_range(0, 12), controller: controller));
    await tester.pumpAndSettle();
    final position = _position(controller);
    expect(position.pixels, position.maxScrollExtent);
    expect(
      controller.scrollable.value,
      const MessageScrollerScrollable(start: true),
    );
  });

  testWidgets('can open at the first message', (tester) async {
    await tester.pumpWidget(
      _chat(
        _range(0, 12),
        controller: controller,
        position: MessageScrollerPosition.start,
      ),
    );
    await tester.pumpAndSettle();
    expect(_position(controller).pixels, 0);
    expect(
      controller.scrollable.value,
      const MessageScrollerScrollable(end: true),
    );
  });

  testWidgets('scrolling up wakes the jump button, which glides back', (
    tester,
  ) async {
    await tester.pumpWidget(_chat(_range(0, 12), controller: controller));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(MessageScrollerViewport),
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();
    expect(controller.scrollable.value.end, isTrue);
    await tester.tap(find.bySemanticsLabel('Scroll to end'));
    await tester.pumpAndSettle();
    final position = _position(controller);
    expect(position.pixels, position.maxScrollExtent);
    expect(controller.scrollable.value.end, isFalse);
  });

  testWidgets('follows new messages until the reader scrolls up', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chat(_range(0, 12), controller: controller, autoScroll: true),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _chat(_range(0, 13), controller: controller, autoScroll: true),
    );
    await tester.pumpAndSettle();
    var position = _position(controller);
    expect(position.pixels, position.maxScrollExtent);
    await tester.drag(
      find.byType(MessageScrollerViewport),
      const Offset(0, 150),
    );
    await tester.pumpAndSettle();
    final reading = _position(controller).pixels;
    await tester.pumpWidget(
      _chat(_range(0, 14), controller: controller, autoScroll: true),
    );
    await tester.pumpAndSettle();
    position = _position(controller);
    expect(position.pixels, reading);
    expect(position.pixels, lessThan(position.maxScrollExtent));
  });

  testWidgets('a new reply comes to the top with a peek above it', (
    tester,
  ) async {
    await tester.pumpWidget(_chat(_range(0, 12), controller: controller));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _chat(_range(0, 13), controller: controller, anchors: {12}),
    );
    await tester.pumpAndSettle();
    expect(_topOf(tester, 12), closeTo(64, 1));
    expect(controller.spacer.value, greaterThan(0));
    expect(controller.visibility.value.currentAnchorId, 'm12');
  });

  testWidgets('prepending keeps the message being read in place', (
    tester,
  ) async {
    await tester.pumpWidget(_chat(_range(20, 32), controller: controller));
    await tester.pumpAndSettle();
    final before = _topOf(tester, 28);
    await tester.pumpWidget(_chat(_range(10, 32), controller: controller));
    await tester.pumpAndSettle();
    expect(_topOf(tester, 28), closeTo(before, 1));
  });

  testWidgets('jumps to a message by id and reports what is in view', (
    tester,
  ) async {
    await tester.pumpWidget(_chat(_range(0, 20), controller: controller));
    await tester.pumpAndSettle();
    expect(controller.scrollToMessage('m5'), isTrue);
    await tester.pumpAndSettle();
    expect(_topOf(tester, 5), closeTo(0, 1));
    expect(controller.visibility.value.visibleMessageIds, contains('m6'));
    expect(controller.scrollToMessage('nope'), isFalse);
  });

  testWidgets('Home and End scroll the focused transcript', (tester) async {
    await tester.pumpWidget(_chat(_range(0, 12), controller: controller));
    await tester.pumpAndSettle();
    controller.viewportFocusNode?.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(_position(controller).pixels, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    expect(_position(controller).pixels, greaterThan(0));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    final position = _position(controller);
    expect(position.pixels, position.maxScrollExtent);
  });

  testWidgets('the viewport is a named region; idle buttons are hidden', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_chat(_range(0, 12), controller: controller));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Messages'), findsOneWidget);
    expect(find.bySemanticsLabel('Scroll to end'), findsNothing);
    expect(find.bySemanticsLabel('Scroll to start'), findsOneWidget);
    handle.dispose();
  });
}
