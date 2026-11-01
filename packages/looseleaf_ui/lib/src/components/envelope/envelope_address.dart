import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The address on an [EnvelopeFront], in the script face on 28 px rows,
/// each ruled by a soft pencil line, at most 62 % of the front's width.
///
/// Mirrors `EnvelopeAddress` in upstream `src/components/ui/envelope.tsx`.
class EnvelopeAddress extends StatelessWidget {
  const EnvelopeAddress({
    super.key,
    required this.children,
    this.cssFontSize = 21.6,
  });

  /// The address lines, usually [Text]s.
  final List<Widget> children;

  /// The CSS font size: `text-[1.35rem]`; small envelopes use 17.6
  /// (`text-[1.1rem]`). The rows stay 28 px.
  final double cssFontSize;

  /// Upstream's `leading-7`.
  static const double row = Spacing.d28;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return FractionallySizedBox(
      widthFactor: 0.62,
      alignment: AlignmentDirectional.centerStart,
      child: CustomPaint(
        painter: _AddressRules(theme.colors.lineSoft),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: cssFontSize,
            cssLineHeight: row / cssFontSize,
            color: theme.colors.ink,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _AddressRules extends CustomPainter {
  const _AddressRules(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (
      var y = EnvelopeAddress.row;
      y <= size.height;
      y += EnvelopeAddress.row
    ) {
      canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_AddressRules oldDelegate) => oldDelegate.color != color;
}
