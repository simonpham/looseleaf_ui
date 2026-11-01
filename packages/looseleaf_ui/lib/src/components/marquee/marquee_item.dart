import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/doodle/doodle.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One phrase on a marquee, followed by a small hand-drawn star 16 px on,
/// and 16 px before the next phrase.
///
/// Mirrors `MarqueeItem` in upstream `src/components/ui/marquee.tsx`.
class MarqueeItem extends StatelessWidget {
  const MarqueeItem(
    this.child, {
    super.key,
    this.separator = star,
  });

  /// Upstream's default separator: a 24 px star doodle at 90%.
  static const Widget star = Opacity(
    opacity: 0.9,
    child: Padding(
      padding: EdgeInsets.only(bottom: Spacing.d2),
      child: Doodle('star', size: Spacing.d24),
    ),
  );

  /// The phrase, usually a [Text].
  final Widget child;

  /// What comes after the phrase: [star] by default, nothing when null.
  final Widget? separator;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: Spacing.d16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d16,
      children: [child, ?separator],
    ),
  );
}
