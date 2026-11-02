import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/faq_01/faq_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An FAQ: a lettered title, the questions on a ruled sheet and a "Still
/// stuck?" card. Wide, the title and the card share a narrow column beside
/// the sheet.
///
/// Mirrors upstream `src/blocks/faq-01/page.tsx`.
class Faq01Block extends StatelessWidget {
  const Faq01Block({super.key});

  static const double _maxWidth = 1024;
  static const double _sideWidth = 272;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final header = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        const Lettering(
          'Questions, answered',
          tone: LetteringTone.grass,
          wobble: 0.4,
          seed: 'faq-title',
          textAlign: TextAlign.start,
        ),
        Text(
          'The ones we get every week, in our own words.',
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 20,
            cssLineHeight: 32 / 20,
            color: theme.colors.inkSoft,
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= 768;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.d32,
            vertical: switch (width >= 576) {
              true => Spacing.d80,
              false => Spacing.d56,
            },
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: switch (wide) {
                true => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d48,
                  children: [
                    SizedBox(
                      width: _sideWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Spacing.d40,
                        children: [header, const Faq01Help()],
                      ),
                    ),
                    const Expanded(child: Faq01Sheet()),
                  ],
                ),
                false => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d40,
                  children: [header, const Faq01Sheet(), const Faq01Help()],
                ),
              },
            ),
          ),
        );
      },
    );
  }
}
