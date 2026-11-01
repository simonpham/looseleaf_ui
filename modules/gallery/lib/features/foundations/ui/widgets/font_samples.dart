import 'package:flutter/widgets.dart';
import 'package:gallery/features/foundations/models/models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A line in each face of [fonts], with its name and role.
class FontSamples extends StatelessWidget {
  const FontSamples({super.key, required this.fonts});

  final List<FontSample> fonts;

  static const String pangram = 'The quick brown fox jots 1234567890';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    TextStyle styleOf(String token) => switch (token) {
      '--font-script' => theme.typography.face(
        KevinSansFace.script,
        cssSize: 30,
        fontWeight: FontWeight.w700,
      ),
      '--font-type' => theme.typography.face(KevinSansFace.type, cssSize: 20),
      '--font-mono' => theme.typography.mono(cssSize: 17),
      _ => theme.typography.face(KevinSansFace.hand, cssSize: 22),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        for (final font in fonts)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d4,
            children: [
              Text(
                '${font.label} · ${font.role} · ${font.token}',
                style: theme.typography.stamp(color: theme.colors.inkMuted),
              ),
              Text(
                pangram,
                style: styleOf(font.token).copyWith(color: theme.colors.ink),
              ),
            ],
          ),
      ],
    );
  }
}
