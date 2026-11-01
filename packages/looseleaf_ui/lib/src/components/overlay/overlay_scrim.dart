import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The dim behind a modal popup, filling its parent: Looseleaf's warm
/// vignette (`--ll-overlay-dim`, lighter where the paper lands, darker at
/// the edges), fading with [opacity]. It blocks the app's semantics below
/// and, when [onDismiss] is set, closes the popup on tap.
///
/// Mirrors `DialogOverlay` in upstream `src/components/ui/dialog.tsx`.
class OverlayScrim extends StatelessWidget {
  const OverlayScrim({
    super.key,
    this.opacity = kAlwaysCompleteAnimation,
    this.onDismiss,
    this.dim = true,
    this.semanticLabel,
  });

  /// Fades the dim.
  final Animation<double> opacity;

  /// Called on tap; taps are only blocked when null.
  final VoidCallback? onDismiss;

  /// False for a clear barrier that only catches taps.
  final bool dim;

  /// What the barrier says to screen readers when it can dismiss.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    Widget scrim = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      excludeFromSemantics: true,
      child: const SizedBox.expand(),
    );
    if (dim) {
      scrim = FadeTransition(
        opacity: opacity,
        child: CustomPaint(painter: _DimPainter(theme), child: scrim),
      );
    }
    return BlockSemantics(
      child: Semantics(
        label: semanticLabel,
        onTap: onDismiss,
        child: scrim,
      ),
    );
  }
}

class _DimPainter extends CustomPainter {
  _DimPainter(this.theme);

  final LooseleafThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final shade = theme.colors.shade;
    final k = theme.shadowK;
    Color at(double alpha) => shade.withValues(alpha: (alpha * k).clamp(0, 1));
    final ellipse = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.38),
      width: size.width * 1.8,
      height: size.height * 1.6,
    );
    canvas
      ..drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Offset.zero & size)
          ..addOval(ellipse),
        Paint()..color = at(0.34),
      )
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(ellipse.center.dx, ellipse.center.dy)
      ..scale(ellipse.width / 2, ellipse.height / 2)
      ..drawCircle(
        Offset.zero,
        1,
        Paint()
          ..shader = RadialGradient(
            colors: [at(0.16), at(0.23), at(0.34)],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1)),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_DimPainter oldDelegate) => oldDelegate.theme != theme;
}
