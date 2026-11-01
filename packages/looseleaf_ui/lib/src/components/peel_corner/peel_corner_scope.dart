import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Which bottom corner of a [PeelCorner] peels.
enum PeelCornerSide { bottomRight, bottomLeft }

/// What a [PeelCorner] tells its parts: whether it is open, which corner
/// peels, and the live peel in pixels (the flap's reach, which follows a
/// drag frame by frame).
///
/// Mirrors `usePeelCorner` in upstream `src/components/ui/peel-corner.tsx`.
class PeelCornerScope extends InheritedWidget {
  const PeelCornerScope({
    super.key,
    required this.open,
    required this.corner,
    required this.peel,
    required super.child,
  });

  /// Whether the corner is open (the sheet underneath can be used).
  final bool open;

  final PeelCornerSide corner;

  /// The peel in pixels: `--peel`, the curl's scale times its size.
  final ValueListenable<double> peel;

  /// The enclosing corner's scope.
  static PeelCornerScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PeelCornerScope>();
    if (scope == null) {
      throw FlutterError('PeelCorner parts must be used inside a PeelCorner.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(PeelCornerScope oldWidget) =>
      oldWidget.open != open ||
      oldWidget.corner != corner ||
      oldWidget.peel != peel;
}
