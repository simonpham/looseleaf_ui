import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An underlined text link in the link ink, darker on hover.
class Login04Link extends StatefulWidget {
  const Login04Link(
    this.label, {
    super.key,
    this.onPressed,
    this.style,
    this.plain = false,
  });

  /// The link's text.
  final String label;

  /// Called on tap.
  final VoidCallback? onPressed;

  /// The text style over the ambient one.
  final TextStyle? style;

  /// Keeps the ink color instead of the link color.
  final bool plain;

  @override
  State<Login04Link> createState() => _Login04LinkState();
}

class _Login04LinkState extends State<Login04Link> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final color = switch ((widget.plain, _hovered)) {
      (true, _) => colors.ink,
      (false, true) => colors.linkHover,
      (false, false) => colors.link,
    };
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed ?? () {},
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
