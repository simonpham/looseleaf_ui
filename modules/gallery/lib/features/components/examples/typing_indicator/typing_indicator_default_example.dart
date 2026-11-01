import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypingIndicatorDefaultExample extends StatelessWidget {
  const TypingIndicatorDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d48,
    runSpacing: Spacing.d24,
    alignment: WrapAlignment.center,
    children: [
      _Figure(
        caption: 'dots',
        child: TypingIndicator(seed: 'dots'),
      ),
      _Figure(
        caption: 'scrawl',
        child: TypingIndicator(variant: TypingVariant.squiggle, seed: 'scrawl'),
      ),
      _Figure(
        caption: 'blue felt, no pencil',
        child: TypingIndicator(pen: TypingPen.you, pencil: false, seed: 'you'),
      ),
    ],
  );
}

class _Figure extends StatelessWidget {
  const _Figure({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        child,
        Text(
          caption,
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.inkMuted,
          ),
        ),
      ],
    );
  }
}
