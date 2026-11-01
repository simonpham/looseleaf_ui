import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const _says = <BubbleVariant, String>{
  BubbleVariant.primary: 'Can you add tags to my notes?',
  BubbleVariant.secondary: 'Tags, then a filter row above the list.',
  BubbleVariant.muted: 'Sure. Give me a minute, I will look at the list first.',
  BubbleVariant.tinted: 'Two tags per note is plenty, I think.',
  BubbleVariant.outline: 'And a way to remove them again?',
  BubbleVariant.destructive: 'That would delete every tag. Are you sure?',
};

Widget _page(Widget child) => RepaintBoundary(
  child: Paper(
    stock: StockName.dotGrid,
    tilt: false,
    shadow: PaperShadow.none,
    seed: 'page',
    padding: const EdgeInsets.all(Spacing.d40),
    child: SizedBox(width: 520, child: child),
  ),
);

Widget _variants() => BubbleGroup(
  gap: Spacing.d16,
  children: [
    for (final (i, MapEntry(key: variant, value: text))
        in _says.entries.indexed)
      Bubble(
        variant: variant,
        align: switch (i.isOdd) {
          true => ChatAlign.end,
          false => ChatAlign.start,
        },
        children: [
          BubbleContent(seed: 'variant-${variant.id}', child: Text(text)),
        ],
      ),
    const Bubble(
      variant: BubbleVariant.ghost,
      children: [
        BubbleContent(
          child: Text(
            'Ghost bubbles are just the words, set in the same hand.',
          ),
        ),
      ],
    ),
  ],
);

Widget _conversation() => const MessageGroup(
  gap: Spacing.d20,
  children: [
    Message(
      children: [
        MessageAvatar(
          child: Mascot(pose: 'idle', size: 36, seed: 'stubby'),
        ),
        MessageContent(
          children: [
            MessageHeader(child: Text('Stubby 9:41')),
            BubbleGroup(
              children: [
                Bubble(
                  variant: BubbleVariant.muted,
                  children: [
                    BubbleContent(
                      seed: 'a1',
                      child: Text('I read src/notes/list.tsx first.'),
                    ),
                  ],
                ),
                Bubble(
                  variant: BubbleVariant.muted,
                  children: [
                    BubbleContent(
                      seed: 'a2',
                      child: Text(
                        'Tags become a string array on Note, with a chip row '
                        'above the list. Want me to draw the chips small?',
                      ),
                    ),
                    BubbleReactions(align: ChatAlign.start, child: Text('+1')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    SizedBox(height: Spacing.d4),
    Message(
      align: ChatAlign.end,
      children: [
        MessageContent(
          children: [
            MessageHeader(child: Text('you')),
            BubbleGroup(
              children: [
                Bubble(
                  children: [
                    BubbleContent(
                      seed: 'u1',
                      child: Text(
                        'Yes, small. And can you put the filter row above '
                        'the list?',
                      ),
                    ),
                  ],
                ),
                Bubble(
                  children: [
                    BubbleContent(seed: 'u2', child: Text('Thank you!')),
                  ],
                ),
              ],
            ),
            MessageFooter(child: Text('seen')),
          ],
        ),
      ],
    ),
  ],
);

Widget _shapes() => const Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: Spacing.d32,
  children: [
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d32,
      children: [
        Expanded(
          child: Bubble(
            shape: BubbleShape.note,
            children: [
              BubbleContent(
                seed: 'note',
                minHeight: Spacing.d56,
                paper: BubblePaper(tiltDegrees: -1.6),
                child: Text('meet me by the library at four'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Bubble(
            shape: BubbleShape.sticky,
            variant: BubbleVariant.secondary,
            children: [
              BubbleContent(
                seed: 'sticky',
                minHeight: Spacing.d96,
                padding: EdgeInsets.fromLTRB(
                  Spacing.d16,
                  Spacing.d28,
                  Spacing.d16,
                  Spacing.d10,
                ),
                paper: BubblePaper(
                  tiltDegrees: 1.8,
                  fastener: FastenerKind.pin,
                ),
                child: Text('buy more ink!'),
              ),
            ],
          ),
        ),
      ],
    ),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d32,
      children: [
        Expanded(
          child: Bubble(
            shape: BubbleShape.sticky,
            variant: BubbleVariant.tinted,
            align: ChatAlign.end,
            children: [
              BubbleContent(
                seed: 'sticky-2',
                minHeight: Spacing.d96,
                paper: BubblePaper(tiltDegrees: -1.4),
                child: Text('call mum before six'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Bubble(
            variant: BubbleVariant.outline,
            pen: BubblePen.you,
            align: ChatAlign.end,
            children: [
              BubbleContent(
                seed: 'you',
                child: Text('Make the chips a little smaller, please.'),
              ),
            ],
          ),
        ),
      ],
    ),
  ],
);

Widget _buttons() => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: Spacing.d12,
  children: [
    for (final (reply, states) in const [
      ('Show me the diff', <InkState>{}),
      ('Run the tests', {InkState.hovered}),
      ('Not now, thanks', {InkState.focused}),
    ])
      Bubble(
        variant: BubbleVariant.outline,
        align: ChatAlign.end,
        tail: false,
        children: [
          BubbleContent(
            seed: reply,
            onPressed: () {},
            forcedStates: states,
            child: Text(reply),
          ),
        ],
      ),
  ],
);

Future<void> _golden(WidgetTester tester, Widget child, String name) async {
  tester.view.physicalSize = const Size(1400, 1600);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_page(child)));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('../goldens/bubble-$name.png'),
  );
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets(
    'bubble variants',
    (tester) => _golden(tester, _variants(), 'variants'),
  );
  testWidgets(
    'bubble conversation',
    (tester) => _golden(tester, _conversation(), 'conversation'),
  );
  testWidgets(
    'bubble shapes',
    (tester) => _golden(tester, _shapes(), 'shapes'),
  );
  testWidgets(
    'bubble buttons',
    (tester) => _golden(tester, _buttons(), 'buttons'),
  );
}
