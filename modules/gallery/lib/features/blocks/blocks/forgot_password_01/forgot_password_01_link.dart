import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An underlined text link in the link ink, darker on hover.
class ForgotPassword01Link extends StatefulWidget {
  const ForgotPassword01Link(
    this.label, {
    super.key,
    this.onPressed,
    this.style,
    this.disabled = false,
  });

  /// The link's text.
  final String label;

  /// Called on tap.
  final VoidCallback? onPressed;

  /// The text style over the ambient one.
  final TextStyle? style;

  /// Greys the link out and ignores taps, like `aria-disabled`.
  final bool disabled;

  @override
  State<ForgotPassword01Link> createState() => _ForgotPassword01LinkState();
}

class _ForgotPassword01LinkState extends State<ForgotPassword01Link> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final color = switch ((widget.disabled, _hovered)) {
      (true, _) => colors.pencilText,
      (false, true) => colors.linkHover,
      (false, false) => colors.link,
    };
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: switch (widget.disabled) {
          true => null,
          false => widget.onPressed ?? () {},
        },
        child: Semantics(
          link: true,
          child: Text(
            widget.label,
            style: (widget.style ?? const TextStyle()).copyWith(
              color: color,
              decoration: TextDecoration.underline,
              decorationColor: color,
            ),
          ),
        ),
      ),
    );
  }
}
