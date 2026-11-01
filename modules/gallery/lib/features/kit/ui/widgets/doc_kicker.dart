import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The small typewriter line above a title, upstream `.dk-kicker`.
class DocKicker extends StatelessWidget {
  const DocKicker(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Text(
      text,
      style: theme.typography.stamp(cssSize: 14, color: theme.colors.inkMuted),
    );
  }
}
