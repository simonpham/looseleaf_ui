import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A script heading, upstream `.dk-heading`: level 2 in blue felt, 3 and 4 in ink.
class DocHeading extends StatelessWidget {
  const DocHeading(this.text, {super.key, this.level = 2});

  final String text;

  /// 2, 3 or 4, like the HTML heading levels.
  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final (size, color) = switch (level) {
      2 => (34.0, theme.colors.inkYou),
      3 => (26.4, theme.colors.ink),
      _ => (20.8, theme.colors.ink),
    };
    return Semantics(
      header: true,
      child: Text(
        text,
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: size,
          cssLineHeight: 1.15,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
