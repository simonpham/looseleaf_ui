import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BubbleSuggestionsExample extends StatefulWidget {
  const BubbleSuggestionsExample({super.key});

  @override
  State<BubbleSuggestionsExample> createState() =>
      _BubbleSuggestionsExampleState();
}

class _BubbleSuggestionsExampleState extends State<BubbleSuggestionsExample> {
  static const _replies = [
    'Show me the diff',
    'Run the tests',
    'Not now, thanks',
  ];
  static const _maxWidth = Spacing.d512;

  String? _picked;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.d16,
            0,
            Spacing.d16,
            Spacing.d24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: Spacing.d12,
            children: [
              for (final reply in _replies)
                Semantics(
                  toggled: _picked == reply,
                  child: Bubble(
                    variant: BubbleVariant.outline,
                    align: ChatAlign.end,
                    tail: false,
                    children: [
                      BubbleContent(
                        seed: reply,
                        onPressed: () => setState(() => _picked = reply),
                        child: Text(reply),
                      ),
                    ],
                  ),
                ),
              Semantics(
                liveRegion: true,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Spacing.d24),
                  child: Text(
                    switch (_picked) {
                      final picked? => 'You picked "$picked"',
                      null => 'Pick a reply',
                    },
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
