import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/envelope/envelope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The address on an [EnvelopeFront], in the script face on 28 px rows,
/// each ruled by a soft pencil line, at most 62 % of the front's width.
/// Without a [cssFontSize], a front narrower than the envelope's 384 px
/// design width shrinks the type and the rows with it (down to the 80 %
/// upstream's small envelopes pick), so a phone-sized envelope keeps its
/// address on the front.
///
/// Mirrors `EnvelopeAddress` in upstream `src/components/ui/envelope.tsx`.
class EnvelopeAddress extends StatelessWidget {
  const EnvelopeAddress({
    super.key,
    required this.children,
    this.cssFontSize,
  });

  /// The address lines, usually [Text]s.
  final List<Widget> children;

  /// The CSS font size, fixed; the rows stay 28 px. Null is upstream's
  /// `text-[1.35rem]` (21.6), scaled to a narrow front. Small envelopes in
  /// upstream's examples use 17.6 (`text-[1.1rem]`).
  final double? cssFontSize;

  /// `text-[1.35rem]`.
  static const double _defaultSize = 21.6;

  /// Upstream's `leading-7`.
  static const double row = Spacing.d28;

  /// Upstream's `max-w-sm`: the front width the sizes are drawn for.
  static const double _designWidth = Spacing.d384;

  /// How far the type may shrink on a narrow front.
  static const double _minScale = 0.8;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final front = EnvelopeFrontScope.maybeOf(context)?.size.width;
    final scale = switch ((cssFontSize, front)) {
      (null, final width?) when width.isFinite => (width / _designWidth).clamp(
        _minScale,
        1.0,
      ),
      _ => 1.0,
    };
    final lineHeight = row * scale;
    final fontSize = (cssFontSize ?? _defaultSize) * scale;
    return FractionallySizedBox(
      widthFactor: 0.62,
      alignment: AlignmentDirectional.centerStart,
      child: CustomPaint(
        painter: _AddressRules(theme.colors.lineSoft, lineHeight),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: fontSize,
            cssLineHeight: lineHeight / fontSize,
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
  const _AddressRules(this.color, this.row);

  final Color color;
  final double row;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = row; y <= size.height; y += row) {
      canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_AddressRules oldDelegate) =>
      oldDelegate.color != color || oldDelegate.row != row;
}
