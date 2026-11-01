import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The rule under an [H1] or [H2]: a full-width 2 px rounded bar in the
/// text color at 55%, 8 px below the text (upstream `RULE`, an `::after`).
class HeadingRule extends StatelessWidget {
  const HeadingRule({super.key});

  static const double _opacity = 0.55;

  @override
  Widget build(BuildContext context) {
    final color =
        DefaultTextStyle.of(context).style.color ??
        LooseleafTheme.of(context).colors.ink;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d8),
      child: SizedBox(
        height: Spacing.d2,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: color.a * _opacity),
            borderRadius: BorderRadius.circular(Spacing.d2),
          ),
        ),
      ),
    );
  }
}
