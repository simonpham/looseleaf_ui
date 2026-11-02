import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An underlined text link in the link ink, darker on hover.
class Login02Link extends StatefulWidget {
  const Login02Link(
    this.label, {
    super.key,
    this.onPressed,
    this.style,
    this.textAlign,
  });

  /// The link's text.
  final String label;

  /// Called on tap.
  final VoidCallback? onPressed;

  /// The text style over the ambient one.
  final TextStyle? style;

  /// How the text aligns when it wraps.
  final TextAlign? textAlign;

  @override
  State<Login02Link> createState() => _Login02LinkState();
}

class _Login02LinkState extends State<Login02Link> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final color = switch (_hovered) {
      true => colors.linkHover,
      false => colors.link,
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
            textAlign: widget.textAlign,
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
