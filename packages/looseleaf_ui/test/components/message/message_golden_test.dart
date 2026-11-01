import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

/// A stand-in for the Bubble component: a plain box around the words.
class _Box extends StatelessWidget {
  const _Box(this.child, {this.mine = false});

  final Widget child;
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
        child: child,
      ),
    );
  }
}

Widget _thread() => const SizedBox(
  width: 480,
  child: MessageGroup(
    gap: Spacing.d20,
    children: [
      Message(
        align: ChatAlign.end,
        children: [
          MessageContent(
            children: [
              MessageHeader(child: Text('Ada')),
              _Box(Text('Which of these should I fix first?'), mine: true),
            ],
          ),
        ],
      ),
      Message(
        children: [
          MessageAvatar(
            child: Mascot(pose: 'write', size: 40, seed: 'thread-mascot'),
          ),
          MessageContent(
            children: [
              MessageHeader(child: Text('Stubby')),
              _Box(
                Text(
                  'The failing test. Everything else can wait until it is '
                  'green.',
                ),
              ),
              _Box(Text('It is a one-line fix in filter.ts.')),
              MessageFooter(child: Text('edited a minute ago')),
            ],
          ),
        ],
      ),
      Message(
        children: [
          MessageContent(
            children: [
              MessageHeader(child: Text('Stubby')),
              _Box(
                MessageText(
                  'Tags now sit under each note as small chips. Pick one or '
                  'two and the list narrows.',
                  streaming: true,
                  seed: 'stream-words',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('message-thread in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(componentHost(goldenPanel(_thread())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/message-thread.png'),
    );
  });
}
