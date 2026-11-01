import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/doc_pressable.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Blue felt link text, underlined, heavier on hover (upstream `.dk-article a`).
class DocLink extends StatelessWidget {
  const DocLink(this.text, {super.key, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return DocPressable(
      onPressed: onPressed,
      builder: (context, highlighted) => Text(
        text,
        style: TextStyle(
          color: switch (highlighted) {
            true => colors.linkHover,
            false => colors.link,
          },
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: colors.link,
          decorationThickness: switch (highlighted) {
            true => 2.5,
            false => 1.5,
          },
        ),
      ),
    );
  }
}
