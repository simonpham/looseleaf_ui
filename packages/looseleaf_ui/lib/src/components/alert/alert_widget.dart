import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/alert/alert.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A boxed message on a slip: an inked outline with a tone of its own (red
/// hatching for `destructive`, a double blue rule for `info`, a green
/// marker strip for `success`, a highlighter panel for `warning`), the
/// [icon] circled in the tone's marker, then [children] (an [AlertTitle]
/// and an [AlertDescription]). [AlertTone.note] is a taped sticky note.
///
/// It fills the width it is given and is a live region, so screen readers
/// announce it when it appears.
///
/// ```dart
/// Alert(
///   variant: AlertTone.destructive,
///   icon: const InkIcon('circle-alert'),
///   children: const [
///     AlertTitle(Text('Unable to process your payment.')),
///     AlertDescription(Text('Please verify your billing information.')),
///   ],
/// )
/// ```
///
/// Mirrors `Alert` in upstream `src/components/ui/alert.tsx`.
class Alert extends StatefulWidget {
  const Alert({
    super.key,
    required this.children,
    this.variant = AlertTone.neutral,
    this.icon,
    this.seed,
  });

  /// The title and description.
  final List<Widget> children;

  /// The tone: upstream's `variant`.
  final AlertTone variant;

  /// An icon before the text, 16 px in the tone's color, circled by the
  /// alert's marker.
  final Widget? icon;

  /// Pins the hand: the same seed always draws the same box.
  final String? seed;

  @override
  State<Alert> createState() => _AlertState();
}

class _AlertState extends State<Alert> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final tone = widget.variant;
    final colors = theme.colors;
    final textColor = switch (tone) {
      AlertTone.destructive => colors.red,
      _ => colors.ink,
    };
    final iconColor = switch (tone) {
      AlertTone.info => colors.inkYou,
      AlertTone.success => colors.green,
      _ => textColor,
    };
    final content = AlertScope(
      tone: tone,
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          color: textColor,
        ),
        child: _layout(iconColor),
      ),
    );
    final padding = _padding(theme.density);
    final alert = switch (tone) {
      AlertTone.note => Paper(
        stock: StockName.stickyYellow,
        tape: PaperTape.corner,
        seed: widget.seed,
        padding: padding,
        child: content,
      ),
      _ => InkSurface(
        source: AlertInkSource(tone: tone, withIcon: widget.icon != null),
        seed: inkSeed(widget.seed),
        still: true,
        child: Padding(padding: padding, child: content),
      ),
    };
    return Semantics(container: true, liveRegion: true, child: alert);
  }

  Widget _layout(Color iconColor) {
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d2,
      children: widget.children,
    );
    final icon = widget.icon;
    if (icon == null) return text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Spacing.d2),
          child: IconTheme.merge(
            data: IconThemeData(size: Spacing.d16, color: iconColor),
            child: SizedBox.square(
              dimension: Spacing.d16,
              child: Center(child: icon),
            ),
          ),
        ),
        Expanded(child: text),
      ],
    );
  }

  /// `px-4 py-3 compact:py-2.5 calm:px-3 calm:py-2`; a note is `px-5 py-4`.
  EdgeInsets _padding(LooseleafDensity density) => switch ((
    widget.variant,
    density,
  )) {
    (_, LooseleafDensity.calm) => const EdgeInsets.symmetric(
      horizontal: Spacing.d12,
      vertical: Spacing.d8,
    ),
    (AlertTone.note, LooseleafDensity.compact) => const EdgeInsets.symmetric(
      horizontal: Spacing.d20,
      vertical: Spacing.d10,
    ),
    (AlertTone.note, _) => const EdgeInsets.symmetric(
      horizontal: Spacing.d20,
      vertical: Spacing.d16,
    ),
    (_, LooseleafDensity.compact) => const EdgeInsets.symmetric(
      horizontal: Spacing.d16,
      vertical: Spacing.d10,
    ),
    _ => const EdgeInsets.symmetric(
      horizontal: Spacing.d16,
      vertical: Spacing.d12,
    ),
  };
}
