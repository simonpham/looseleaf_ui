import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The footer's brand: Stubby and the penmark word mark, a line about the
/// team, and a round "hand made" rubber stamp. Stacked when [stacked].
///
/// Mirrors upstream `src/blocks/footer-01/components/footer-01-brand.tsx`.
class Footer01Brand extends StatelessWidget {
  const Footer01Brand({super.key, this.stacked = false});

  /// Whether the stamp goes under the text instead of beside it.
  final bool stacked;

  static const double _textWidth = 320;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final about = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _textWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d8,
            children: [
              const Mascot(size: 40),
              Text(
                'penmark',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 36,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
            ],
          ),
          Text(
            'Notes and tasks for small teams, drawn by hand in Lisbon and kept in a drawer in Porto.',
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 16,
              cssLineHeight: 28 / 16,
              color: theme.colors.ink,
            ),
          ),
        ],
      ),
    );
    const stamp = Stamp(
      shape: StampShape.round,
      text: 'hand made',
      ring: 'PENMARK * DRAWN IN LISBON *',
      ink: StampPadInk.inkYou,
      size: 112,
      tilt: -9,
      seed: 'footer-stamp',
      semanticLabel: 'Stamp: hand made, drawn in Lisbon',
    );
    return switch (stacked) {
      true => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [about, stamp],
      ),
      false => Wrap(
        spacing: Spacing.d24,
        runSpacing: Spacing.d16,
        children: [about, stamp],
      ),
    };
  }
}
