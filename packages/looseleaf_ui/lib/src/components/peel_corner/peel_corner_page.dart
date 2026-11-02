import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/peel_corner/peel_corner_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The top sheet of a [PeelCorner]: a flat [Paper] whose corner is cut away
/// along the curl's fold as it peels, showing the [PeelCornerUnder] below.
/// It sets the corner's size; give it one from outside or let its content
/// size it.
///
/// Mirrors `PeelCornerPage` in upstream `src/components/ui/peel-corner.tsx`.
class PeelCornerPage extends StatelessWidget {
  const PeelCornerPage({
    super.key,
    required this.child,
    this.stock = StockName.paper,
    this.tilt = false,
    this.padding = const EdgeInsets.all(Spacing.d20),
    this.height,
    this.seed,
  });

  /// What is written on the page.
  final Widget child;

  final StockName stock;

  /// Tilts the sheet; flat by default.
  final bool tilt;

  /// `p-5`.
  final EdgeInsetsGeometry padding;

  /// The sheet's height (upstream's `h-*` class, `h-52` in the docs);
  /// null lets the content size it.
  final double? height;

  /// Pins the sheet's tooth.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = PeelCornerScope.of(context);
    final page = ClipPath(
      clipper: PeelCornerClipper(peel: scope.peel, corner: scope.corner),
      child: Paper(
        stock: stock,
        tilt: tilt,
        padding: padding,
        seed: seed,
        child: child,
      ),
    );
    return switch (height) {
      final fixed? => SizedBox(height: fixed, child: page),
      null => page,
    };
  }
}

/// Cuts the peeled corner off a sheet along the fold: everything past the
/// diagonal [peel] pixels in from the corner, with 40 px of room on the
/// other sides for the sheet's shadow.
///
/// Mirrors the `clip-path` polygons of `PeelCornerPage` in upstream
/// `src/components/ui/peel-corner.tsx`.
class PeelCornerClipper extends CustomClipper<Path> {
  PeelCornerClipper({required this.peel, required this.corner})
    : super(reclip: peel);

  static const double _room = 40;

  final ValueListenable<double> peel;
  final PeelCornerSide corner;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final p = peel.value;
    const m = _room;
    final points = switch (corner) {
      PeelCornerSide.bottomRight => [
        const Offset(-m, -m),
        Offset(w + m, -m),
        Offset(w + m, h - p - m),
        Offset(w - p - m, h + m),
        Offset(-m, h + m),
      ],
      PeelCornerSide.bottomLeft => [
        const Offset(-m, -m),
        Offset(w + m, -m),
        Offset(w + m, h + m),
        Offset(p + m, h + m),
        Offset(-m, h - p - m),
      ],
    };
    return Path()..addPolygon(points, true);
  }

  @override
  bool shouldReclip(PeelCornerClipper oldClipper) =>
      oldClipper.peel != peel || oldClipper.corner != corner;
}
