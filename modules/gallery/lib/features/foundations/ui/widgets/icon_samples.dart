import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A row of doodle icons at the sizes they are redrawn for.
class IconSamples extends StatelessWidget {
  const IconSamples({super.key});

  static const List<String> names = [
    'pencil',
    'bell',
    'search',
    'settings',
    'heart',
    'calendar',
    'trash',
    'star',
    'mail',
    'home',
  ];

  static const List<double> sizes = [
    Spacing.d16,
    Spacing.d20,
    Spacing.d24,
    Spacing.d32,
    Spacing.d48,
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d24,
    children: [
      Wrap(
        spacing: Spacing.d20,
        runSpacing: Spacing.d20,
        children: [for (final name in names) InkIcon(name, size: Spacing.d32)],
      ),
      Wrap(
        spacing: Spacing.d20,
        runSpacing: Spacing.d20,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [for (final size in sizes) InkIcon('bell', size: size)],
      ),
    ],
  );
}
