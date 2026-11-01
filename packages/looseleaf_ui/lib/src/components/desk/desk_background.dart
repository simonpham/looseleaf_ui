import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The desk under the paper, filling its parent: the desk colour, a linen
/// weave and the lamp's vignette, darker towards the edges. [lamp] scales
/// the vignette (0 turns it off, 1 is upstream's default).
///
/// Mirrors the `ll-desk` utility of upstream `src/styles/looseleaf.css` and
/// `lampVignette` in `src/components/ui/desk.tsx`.
class DeskBackground extends StatelessWidget {
  const DeskBackground({super.key, this.lamp = 1});

  /// How strong the vignette is.
  final double lamp;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DeskPainter(theme: LooseleafTheme.of(context), lamp: lamp),
    child: const SizedBox.expand(),
  );
}

class _DeskPainter extends CustomPainter {
  _DeskPainter({required this.theme, required this.lamp})
    : super(repaint: InkTextures.instance);

  final LooseleafThemeData theme;
  final double lamp;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.drawRect(area, Paint()..color = theme.colors.desk);
    const tile = PaperTileName.linen;
    if (InkTextures.instance.paper(tile.name) case final image?) {
      final matrix = Float64List(16)
        ..[0] = tile.cssWidth / image.width
        ..[5] = tile.cssHeight / image.height
        ..[10] = 1
        ..[15] = 1;
      canvas.drawRect(
        area,
        Paint()
          ..filterQuality = FilterQuality.low
          ..shader = ImageShader(
            image,
            TileMode.repeated,
            TileMode.repeated,
            matrix,
          ),
      );
    }
    if (lamp <= 0 || size.isEmpty) return;
    final alpha = (lamp * lamp * 0.05 * theme.shadowK).clamp(0.0, 1.0);
    final shade = theme.colors.shade;
    canvas
      ..save()
      ..clipRect(area)
      ..translate(size.width * 0.5, size.height * 0.4)
      ..scale(size.width * 1.2, size.height)
      ..drawRect(
        const Rect.fromLTRB(-2, -2, 2, 2),
        Paint()
          ..shader = RadialGradient(
            colors: [
              shade.withValues(alpha: 0),
              shade.withValues(alpha: 0),
              shade.withValues(alpha: alpha),
            ],
            stops: const [0, 0.6, 1],
          ).createShader(const Rect.fromLTRB(-1, -1, 1, 1)),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_DeskPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.lamp != lamp;
}
