import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The size of a [QuoteText]'s quote marks, and the gutters they need.
///
/// Mirrors `SIZE` and `PADDING` in upstream `src/components/ui/quote.tsx`.
enum QuoteSize {
  /// 24 px marks: `ps-10 pe-8 py-1`.
  sm(
    24,
    EdgeInsetsDirectional.fromSTEB(
      Spacing.d40,
      Spacing.d4,
      Spacing.d32,
      Spacing.d4,
    ),
  ),

  /// 32 px marks: `ps-[3.25rem] pe-10 py-1.5`.
  md(
    32,
    EdgeInsetsDirectional.fromSTEB(
      Spacing.d52,
      Spacing.d6,
      Spacing.d40,
      Spacing.d6,
    ),
  ),

  /// 46 px marks: `ps-[4.75rem] pe-14 py-2`.
  lg(
    46,
    EdgeInsetsDirectional.fromSTEB(
      Spacing.d76,
      Spacing.d8,
      Spacing.d56,
      Spacing.d8,
    ),
  );

  const QuoteSize(this.markSize, this.padding);

  /// The quote marks' size, in px.
  final double markSize;

  /// The gutters around the words.
  final EdgeInsetsDirectional padding;
}
