import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A count beside a nav section or group, in blue felt script.
class NavCount extends StatelessWidget {
  const NavCount(this.count, {super.key, this.large = false});

  final int count;

  /// The section size, bigger than a group's.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Text(
      '$count',
      style: theme.typography.face(
        KevinSansFace.script,
        cssSize: switch (large) {
          true => 20,
          false => 16,
        },
        cssLineHeight: 1,
        fontWeight: FontWeight.w700,
        color: theme.colors.inkYou,
      ),
    );
  }
}
