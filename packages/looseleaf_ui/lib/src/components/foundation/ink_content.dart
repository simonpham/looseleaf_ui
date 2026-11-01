import 'package:flutter/widgets.dart';

/// Styles a component's content slot: the label's text style and the size
/// and color of icons inside, like upstream's typography classes plus
/// `IconSizeContext` (`[&_svg]:size-4`).
///
/// Icons read [IconTheme], so an `Icon` (or any icon widget that honours
/// [IconTheme]) in the slot is sized and colored without arguments.
class InkContent extends StatelessWidget {
  const InkContent({
    super.key,
    required this.style,
    required this.child,
    this.iconSize,
    this.wrap = true,
  });

  /// The text style; its color also colors icons.
  final TextStyle style;

  /// The icon size; null keeps the ambient one.
  final double? iconSize;

  /// Whether text wraps; false is CSS `whitespace-nowrap`.
  final bool wrap;

  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: style,
    softWrap: wrap,
    child: IconTheme.merge(
      data: IconThemeData(size: iconSize, color: style.color),
      child: child,
    ),
  );
}
