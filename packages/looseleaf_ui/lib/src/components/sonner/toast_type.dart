import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';

/// The kind of a toast: the paper it is written on, its tilt and its icon,
/// from the `data-[type=*]` classes of upstream `src/components/ui/sonner.tsx`.
enum ToastType {
  /// A plain slip.
  normal(StockName.slip, PaperShadow.slip, -0.3, null),

  /// A green guest check.
  success(StockName.check, PaperShadow.check, -0.5, 'circle-check'),

  /// A pink sticky.
  error(StockName.stickyPink, PaperShadow.sticky, 0.9, 'octagon-x'),

  /// A yellow sticky.
  warning(StockName.stickyYellow, PaperShadow.sticky, -0.8, 'triangle-alert'),

  /// A blue sticky.
  info(StockName.stickyBlue, PaperShadow.sticky, 0.6, 'info'),

  /// A slip with a spinning loader.
  loading(StockName.slip, PaperShadow.slip, 0.35, 'loader-circle');

  const ToastType(this.stock, this.shadow, this.tilt, this.icon);

  final StockName stock;

  /// The sheet's shadow (`ll-sheet-*`).
  final PaperShadow shadow;

  /// `--ll-tilt` in degrees.
  final double tilt;

  /// The icon name; none for [normal].
  final String? icon;
}
