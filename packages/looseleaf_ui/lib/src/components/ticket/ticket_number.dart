import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A ticket's serial number: the type face, widely tracked, with tabular
/// figures, in a red darkened with ink. 14 px; the stub's big number is
/// usually [cssSize] 18 or 20.
///
/// Mirrors `TicketNumber` in upstream `src/components/ui/ticket.tsx`.
class TicketNumber extends StatelessWidget {
  const TicketNumber(this.child, {super.key, this.cssSize = 14});

  /// The number, usually a [Text].
  final Widget child;

  /// The CSS font size: `text-sm`, `text-lg` (18) or `text-xl` (20).
  final double cssSize;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final style = theme.typography.face(
      KevinSansFace.type,
      cssSize: cssSize,
      cssLineHeight: switch (cssSize) {
        14 => 20 / 14,
        18 => 28 / 18,
        _ => 1.4,
      },
      color: Color.lerp(colors.ink, colors.red, 0.6),
    );
    return DefaultTextStyle.merge(
      style: style.copyWith(
        letterSpacing: (style.fontSize ?? cssSize) * 0.1,
        fontFeatures: const [
          FontFeature.tabularFigures(),
          FontFeature.liningFigures(),
        ],
      ),
      child: child,
    );
  }
}
