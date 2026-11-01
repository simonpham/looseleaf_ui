import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Muted small print, upstream `.dk-hint`.
class DocHint extends StatelessWidget {
  const DocHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Text(
      text,
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 15,
        cssLineHeight: 1.45,
        color: theme.colors.inkMuted,
      ),
    );
  }
}
