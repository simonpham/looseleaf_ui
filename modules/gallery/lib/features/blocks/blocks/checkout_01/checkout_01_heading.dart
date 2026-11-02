import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A numbered step heading: "1 Who is it for?".
class Checkout01Heading extends StatelessWidget {
  const Checkout01Heading({
    super.key,
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final style = theme.typography.face(
      KevinSansFace.script,
      cssSize: 30,
      cssLineHeight: 1,
      fontWeight: FontWeight.w600,
      color: theme.colors.ink,
    );
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: Spacing.d12,
        children: [
          Text('$number', style: style.copyWith(color: theme.colors.inkYou)),
          Flexible(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
