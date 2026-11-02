import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

class BracketDefaultExample extends StatelessWidget {
  const BracketDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Bracket(
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 17,
            cssLineHeight: 1.6,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Text(
                'These two paragraphs are one idea, and the bracket says so.',
              ),
              Text(
                'You could nod and keep reading, or you could underline them '
                'and come back next week.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
