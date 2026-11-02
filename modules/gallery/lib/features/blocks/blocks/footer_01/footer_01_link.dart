import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A footer link: 16 px ink text that gets a highlighter swipe on hover,
/// underlined when [underline] is set.
class Footer01Link extends StatefulWidget {
  const Footer01Link(
    this.label, {
    super.key,
    this.onPressed,
    this.underline = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.d8,
      vertical: Spacing.d4,
    ),
  });

  /// The link's text.
  final String label;

  /// Called on tap.
  final VoidCallback? onPressed;

  /// Whether the text is underlined.
  final bool underline;

  /// The room around the text, inside the swipe.
  final EdgeInsetsGeometry padding;

  @override
  State<Footer01Link> createState() => _Footer01LinkState();
}

class _Footer01LinkState extends State<Footer01Link> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed ?? () {},
        child: Semantics(
          link: true,
          child: SidebarSwipe(
            on: _hovered,
            child: Padding(
              padding: widget.padding,
              child: Text(
                widget.label,
                style: TextStyle(
                  color: colors.ink,
                  decoration: switch (widget.underline) {
                    true => TextDecoration.underline,
                    false => TextDecoration.none,
                  },
                  decorationColor: colors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
