import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const _lines = [
  'Did the tags make it into the build?',
  'They did. The filter row is next.',
  'Can you draw the chips a little smaller?',
  'Smaller, yes. Two pixels off the padding.',
  'And the count at the top?',
  'It says 12 but the list has 11.',
  'Off by one, as ever.',
  'Found it: the archived note still counts.',
  'Fixed. Do you want a test for it?',
  'Yes please. One that would have caught it.',
  'Written. It fails on the old code and passes on the new.',
  'Lovely. Ship it after lunch?',
];

/// A stand-in for the Bubble component: a plain box around the words.
class _Box extends StatelessWidget {
  const _Box(this.text, {required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return ColoredBox(
      color: switch (mine) {
        true => colors.sky,
        false => colors.paperShade,
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d16,
          vertical: Spacing.d8,
        ),
        child: Text(text),
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('message-scroller-faded after scrolling up', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final controller = MessageScrollerController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 420,
            height: 380,
            child: MessageScrollerProvider(
              controller: controller,
              child: MessageScroller(
                children: [
                  MessageScrollerViewport(
                    child: MessageScrollerContent(
                      children: [
                        for (final (i, line) in _lines.indexed)
                          MessageScrollerItem(
                            messageId: 'm$i',
                            child: Message(
                              align: switch (i.isOdd) {
                                true => ChatAlign.end,
                                false => ChatAlign.start,
                              },
                              children: [
                                MessageContent(
                                  children: [_Box(line, mine: i.isOdd)],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const MessageScrollerButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    controller.scrollToMessage('m4', align: MessageScrollerAlign.center);
    await tester.pumpAndSettle();
    await expectLater(
      find.byWidgetPredicate(
        (widget) => widget is RepaintBoundary && widget.child is ColoredBox,
      ),
      matchesGoldenFile('../goldens/message-scroller-faded.png'),
    );
  });
}
