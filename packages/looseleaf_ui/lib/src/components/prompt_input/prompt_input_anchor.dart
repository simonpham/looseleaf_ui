import 'package:flutter/widgets.dart';

/// Where a [PromptInput] sits, for its suggestions list: the link to follow
/// and the paper's width.
class PromptInputAnchor extends InheritedWidget {
  const PromptInputAnchor({
    super.key,
    required this.link,
    required this.width,
    required super.child,
  });

  /// Follows the paper.
  final LayerLink link;

  /// The paper's width.
  final double width;

  /// The nearest anchor.
  static PromptInputAnchor of(BuildContext context) {
    final anchor = context
        .dependOnInheritedWidgetOfExactType<PromptInputAnchor>();
    if (anchor == null) {
      throw FlutterError(
        'PromptInputAnchor.of() called outside a PromptInput.',
      );
    }
    return anchor;
  }

  @override
  bool updateShouldNotify(PromptInputAnchor oldWidget) =>
      oldWidget.link != link || oldWidget.width != width;
}
