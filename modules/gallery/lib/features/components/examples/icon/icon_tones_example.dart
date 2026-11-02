import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _names = [
  'triangle-alert',
  'info',
  'bell',
  'search',
  'user',
  'calendar',
  'circle-check',
];

const _accents = [
  ArtAccent.tomato,
  ArtAccent.tangerine,
  ArtAccent.grass,
  ArtAccent.teal,
  ArtAccent.sky,
  ArtAccent.grape,
  ArtAccent.bubblegum,
];

class IconTonesExample extends StatelessWidget {
  const IconTonesExample({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d16,
    children: [
      _Row(
        label: 'ui',
        icons: [for (final name in _names) InkIcon(name, size: Spacing.d32)],
      ),
      _Row(
        label: 'doodle',
        icons: [
          for (final name in _names)
            InkIcon(name, size: Spacing.d32, tone: ArtTone.doodle),
        ],
      ),
      _Row(
        label: 'accent',
        icons: [
          for (final accent in _accents)
            InkIcon(
              'bell',
              size: Spacing.d32,
              tone: ArtTone.doodle,
              accent: accent,
            ),
        ],
      ),
    ],
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.icons});

  final String label;
  final List<Widget> icons;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d20,
      children: [
        SizedBox(
          width: Spacing.d64,
          child: Text(
            label,
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.pencilText,
            ),
          ),
        ),
        ...icons,
      ],
    );
  }
}
