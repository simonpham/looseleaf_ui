import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An inline text link: underlined, in the link ink.
class Signup02Link extends StatelessWidget {
  const Signup02Link(this.text, {super.key, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed ?? () {},
          child: Text(
            text,
            style: TextStyle(
              color: colors.link,
              decoration: TextDecoration.underline,
              decorationColor: colors.link,
            ),
          ),
        ),
      ),
    );
  }
}
