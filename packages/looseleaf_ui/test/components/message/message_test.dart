import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _message({ChatAlign align = ChatAlign.start, bool footer = false}) =>
    SizedBox(
      width: 400,
      child: Message(
        align: align,
        children: [
          const MessageAvatar(child: SizedBox.square(dimension: 24)),
          MessageContent(
            children: [
              const MessageHeader(child: Text('Lin')),
              const SizedBox(width: 120, height: 40),
              if (footer) const MessageFooter(child: Text('seen 9:14')),
            ],
          ),
        ],
      ),
    );

void main() {
  test('split keeps words at even indexes like String.split(/(\\s+)/)', () {
    expect(MessageText.split('a  b c'), ['a', '  ', 'b', ' ', 'c']);
    expect(MessageText.split(' a '), ['', ' ', 'a', ' ', '']);
    expect(MessageText.isBidi('שלום'), isTrue);
    expect(MessageText.isBidi('hello'), isFalse);
  });

  test('jitter is seeded and small', () {
    final a = MessageText.jitterOf('seed', 0);
    expect(MessageText.jitterOf('seed', 0), a);
    expect(a.dy.abs(), lessThanOrEqualTo(0.6));
    expect(a.ink, inInclusiveRange(0.88, 1));
  });

  testWidgets('end messages mirror the row', (tester) async {
    await tester.pumpWidget(componentHost(_message()));
    final avatar = tester.getCenter(find.byType(MessageAvatar));
    final content = tester.getCenter(find.byType(MessageContent));
    expect(avatar.dx, lessThan(content.dx));
    await tester.pumpWidget(componentHost(_message(align: ChatAlign.end)));
    expect(
      tester.getCenter(find.byType(MessageAvatar)).dx,
      greaterThan(tester.getCenter(find.byType(MessageContent)).dx),
    );
    expect(
      tester.getTopRight(find.text('Lin')).dx,
      closeTo(tester.getTopRight(find.byType(MessageContent)).dx - 12, 0.5),
    );
  });

  testWidgets('a footer lifts the avatar beside the last bubble', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_message()));
    final rest = tester.getBottomLeft(find.byType(SizedBox).at(1));
    await tester.pumpWidget(componentHost(_message(footer: true)));
    await tester.pump();
    final lifted = tester
        .getBottomLeft(
          find.descendant(
            of: find.byType(MessageAvatar),
            matching: find.byType(SizedBox),
          ),
        )
        .dy;
    final footer = tester.getBottomLeft(find.byType(MessageFooter)).dy;
    expect(lifted, closeTo(footer - 32, 0.5));
    expect(rest, isNotNull);
    await tester.pumpWidget(componentHost(_message()));
    await tester.pump();
    expect(
      tester
          .getBottomLeft(
            find.descendant(
              of: find.byType(MessageAvatar),
              matching: find.byType(SizedBox),
            ),
          )
          .dy,
      closeTo(tester.getBottomLeft(find.byType(MessageContent)).dy, 0.5),
    );
  });

  testWidgets('header and footer are 14 px muted notes', (tester) async {
    const colors = LooseleafColors();
    await tester.pumpWidget(componentHost(_message(footer: true)));
    for (final text in ['Lin', 'seen 9:14']) {
      final style = tester
          .renderObject<RenderParagraph>(find.text(text))
          .text
          .style;
      expect(style?.color, colors.inkMuted, reason: text);
    }
    final header = tester
        .renderObject<RenderParagraph>(find.text('Lin'))
        .text
        .style;
    expect(header?.fontWeight, FontWeight.w700);
  });

  testWidgets('MessageText reads as plain text, words then the caret', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const MessageText('Pick one or two', streaming: true, seed: 's'),
      ),
    );
    expect(find.bySemanticsLabel('Pick one or two'), findsOneWidget);
    expect(find.byType(MessageWord), findsNWidgets(4));
    expect(find.byType(MessageCaret), findsOneWidget);
    await tester.pumpWidget(
      componentHost(const MessageText('Pick one or two', seed: 's')),
    );
    expect(find.byType(MessageCaret), findsNothing);
    handle.dispose();
  });

  testWidgets('only words that arrive while streaming soak in', (
    tester,
  ) async {
    Widget text(String words) =>
        componentHost(MessageText(words, streaming: true, seed: 's'));
    await tester.pumpWidget(text('One two'));
    await tester.pumpWidget(text('One two three'));
    final words = tester
        .widgetList<MessageWord>(find.byType(MessageWord))
        .toList();
    expect([for (final w in words) w.soak], [false, false, true]);
    await tester.pump(MessageWord.soakDuration);
  });

  testWidgets('right-to-left text stays one run', (tester) async {
    await tester.pumpWidget(
      componentHost(const MessageText('שלום עולם', streaming: true)),
    );
    expect(find.byType(MessageWord), findsNothing);
    expect(find.byType(MessageCaret), findsOneWidget);
  });

  testWidgets('calm density sets the words on the line', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const MessageText('one two', seed: 's'),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    for (final word in tester.widgetList<MessageWord>(
      find.byType(MessageWord),
    )) {
      expect(word.dy, 0);
      expect(word.ink, 1);
    }
  });

  testWidgets('a ghost bubble pulls the header and footer flush', (
    tester,
  ) async {
    Widget message(BubbleVariant variant) => componentHost(
      SizedBox(
        width: 400,
        child: Message(
          children: [
            MessageContent(
              children: [
                const MessageHeader(child: Text('Stubby')),
                Bubble(
                  variant: variant,
                  children: const [BubbleContent(child: Text('words'))],
                ),
                const MessageFooter(child: Text('seen')),
              ],
            ),
          ],
        ),
      ),
    );
    double inset(String text) =>
        tester.getTopLeft(find.text(text)).dx -
        tester.getTopLeft(find.byType(MessageContent)).dx;

    await tester.pumpWidget(message(BubbleVariant.muted));
    await tester.pump();
    expect(inset('Stubby'), 12);
    expect(inset('seen'), 12);

    await tester.pumpWidget(message(BubbleVariant.ghost));
    await tester.pump();
    expect(inset('Stubby'), 0);
    expect(inset('seen'), 0);
    expect(inset('words'), 0);
  });
}
