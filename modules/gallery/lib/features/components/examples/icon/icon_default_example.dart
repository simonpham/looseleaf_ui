import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _names = [
  'check',
  'x',
  'plus',
  'minus',
  'search',
  'chevron-down',
  'arrow-right',
  'copy',
  'trash',
  'pencil',
  'user',
  'settings',
  'calendar',
  'ellipsis',
];

class IconDefaultExample extends StatelessWidget {
  const IconDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d20,
    runSpacing: Spacing.d20,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [for (final name in _names) InkIcon(name)],
  );
}
