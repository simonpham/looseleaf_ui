import 'package:looseleaf_ui/src/theme/theme.dart';

/// A [Progress] bar's height, upstream's `sizes` in
/// `src/components/ui/progress.tsx`.
enum ProgressSize {
  /// `h-3`.
  sm(Spacing.d12),

  /// `h-4`.
  regular(Spacing.d16),

  /// `h-5`.
  lg(Spacing.d20);

  const ProgressSize(this.height);

  final double height;
}
