import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An inline text link: underlined, in the link ink or, with [ink], in the
/// text's own ink.
class Signup04Link extends StatelessWidget {
  const Signup04Link(
    this.text, {
    super.key,
    this.onPressed,
    this.ink = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool ink;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final color = switch (ink) {
      true => colors.ink,
      false => colors.link,
    };
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed ?? () {},
          child: Text(
            text,
            style: TextStyle(
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
