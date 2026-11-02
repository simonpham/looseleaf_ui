import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScrollAreaMessagesExample extends StatefulWidget {
  const ScrollAreaMessagesExample({super.key});

  @override
  State<ScrollAreaMessagesExample> createState() =>
      _ScrollAreaMessagesExampleState();
}

class _ScrollAreaMessagesExampleState extends State<ScrollAreaMessagesExample> {
  final _lines = [
    ('Ada', 'Did the tabs land?'),
    ('Jo', 'Yes, and the binder ones too.'),
    ('Ada', 'Lovely. Can you look at the table rules?'),
    ('Jo', 'Pencil, by hand. They wander a little.'),
    ('Ada', 'Good. That is the point.'),
    ('Mika', 'I redrew the checkbox tick again.'),
    ('Jo', 'Which of the four?'),
    ('Mika', 'The one that overshoots.'),
  ];
  final _draft = TextEditingController();
  final _log = ScrollController();

  @override
  void initState() {
    super.initState();
    _draft.addListener(_onDraft);
  }

  @override
  void dispose() {
    _draft
      ..removeListener(_onDraft)
      ..dispose();
    _log.dispose();
    super.dispose();
  }

  void _onDraft() => setState(() {});

  void _send() {
    setState(() => _lines.add(('You', _draft.text.trim())));
    _draft.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_log.hasClients) _log.jumpTo(_log.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.interface(cssSize: 14);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Card(
        seed: 'messages',
        gap: Spacing.d16,
        children: [
          const CardHeader(children: [CardTitle(Text('Studio'))]),
          CardContent(
            child: Semantics(
              label: 'Messages',
              child: SizedBox(
                height: Spacing.d224,
                child: ScrollArea(
                  controller: _log,
                  bleed: true,
                  type: ScrollAreaType.always,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d12,
                    children: [
                      for (final (who, text) in _lines)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              who,
                              style: small.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              text,
                              style: small.copyWith(
                                color: theme.colors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          CardFooter(
            spacing: Spacing.d8,
            children: [
              Expanded(
                child: Input(
                  controller: _draft,
                  semanticLabel: 'Your message',
                  placeholder: 'Say something',
                ),
              ),
              Button(
                size: ButtonSize.sm,
                disabled: _draft.text.trim().isEmpty,
                onPressed: _send,
                child: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
