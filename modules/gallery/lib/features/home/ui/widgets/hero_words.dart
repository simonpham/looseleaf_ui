import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The hero's words: the name, the tagline underlined in marker, the
/// pitch, the two ways in and the meta line.
class HeroWords extends StatelessWidget {
  const HeroWords({
    super.key,
    required this.roomy,
    required this.componentCount,
    required this.onGetStarted,
    required this.onBrowse,
  });

  /// Widths from which the type grows (upstream `@xl`).
  static const double roomyFrom = 576;

  static const double _pitchWidth = 512;

  /// Whether the type is set at its larger sizes.
  final bool roomy;
  final int componentCount;
  final VoidCallback onGetStarted;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final tagline = theme.typography.face(
      KevinSansFace.script,
      cssSize: switch (roomy) {
        true => 36,
        false => 30,
      },
      cssLineHeight: 1.25,
      fontWeight: FontWeight.w700,
      color: theme.colors.ink,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Looseleaf',
            style: theme.typography.face(
              KevinSansFace.script,
              cssSize: switch (roomy) {
                true => 96,
                false => 72,
              },
              cssLineHeight: 0.95,
              fontWeight: FontWeight.w700,
              color: theme.colors.ink,
            ),
          ),
        ),
        const SizedBox(height: Spacing.d20),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.d8,
          children: [
            Text('shadcn/ui,', style: tagline),
            Underline(
              tone: MarkPen.marker,
              seed: 'tagline',
              child: Text('drawn by hand.', style: tagline),
            ),
          ],
        ),
        const SizedBox(height: Spacing.d20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _pitchWidth),
          child: Text(
            '$componentCount components as real, accessible Flutter widgets. Same parts and props as shadcn/ui.',
            style: theme.typography.interface(
              cssSize: 18,
              color: theme.colors.inkSoft,
            ),
          ),
        ),
        const SizedBox(height: Spacing.d28),
        Wrap(
          spacing: Spacing.d16,
          runSpacing: Spacing.d16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Button(
              size: ButtonSize.lg,
              seed: 'cta-start',
              onPressed: onGetStarted,
              trailing: const InkIcon('arrow-right'),
              child: const Text('Get started'),
            ),
            Button(
              size: ButtonSize.lg,
              variant: ButtonVariant.outline,
              seed: 'cta-browse',
              onPressed: onBrowse,
              child: const Text('Browse components'),
            ),
          ],
        ),
        const SizedBox(height: Spacing.d24),
        Text(
          'Flutter / Dart 3 / MIT',
          style: theme.typography.stamp(
            cssSize: 14,
            color: theme.colors.inkSoft,
          ),
        ),
      ],
    );
  }
}
