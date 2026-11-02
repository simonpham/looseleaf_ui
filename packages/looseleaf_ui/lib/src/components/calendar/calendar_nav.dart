import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_metrics.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The previous / next month [Button]s across the top of a [Calendar].
///
/// At the ends of `startMonth` / `endMonth` a button fades to 40% and
/// stops answering. Right to left, the chevrons turn round.
///
/// Mirrors `CalendarNavButton` and the `nav` part of upstream
/// `src/components/ui/calendar.tsx`.
class CalendarNav extends StatelessWidget {
  const CalendarNav({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.seed,
    this.canPrevious = true,
    this.canNext = true,
    this.variant = ButtonVariant.ghost,
    this.previousLabel = 'Go to the Previous Month',
    this.nextLabel = 'Go to the Next Month',
    this.cellSize,
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Pins the buttons.
  final String seed;

  /// Whether an earlier month may be shown.
  final bool canPrevious;

  /// Whether a later month may be shown.
  final bool canNext;

  /// The buttons' variant, upstream's `buttonVariant`.
  final ButtonVariant variant;

  final String previousLabel;
  final String nextLabel;

  /// The row's height; [CalendarMetrics.cell] for the density when null.
  final double? cellSize;

  Widget _button({
    required bool enabled,
    required VoidCallback onPressed,
    required String icon,
    required String label,
    required String seed,
  }) => Opacity(
    opacity: switch (enabled) {
      true => 1,
      false => 0.4,
    },
    child: Button(
      variant: variant,
      size: ButtonSize.iconSm,
      disabled: !enabled,
      seed: seed,
      semanticLabel: label,
      onPressed: onPressed,
      child: InkIcon(icon, size: CalendarMetrics.chevron),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      height: cellSize ?? CalendarMetrics.cell.resolve(theme.density),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _button(
            enabled: canPrevious,
            onPressed: onPrevious,
            icon: switch (rtl) {
              true => 'chevron-right',
              false => 'chevron-left',
            },
            label: previousLabel,
            seed: '$seed|previous',
          ),
          _button(
            enabled: canNext,
            onPressed: onNext,
            icon: switch (rtl) {
              true => 'chevron-left',
              false => 'chevron-right',
            },
            label: nextLabel,
            seed: '$seed|next',
          ),
        ],
      ),
    );
  }
}
