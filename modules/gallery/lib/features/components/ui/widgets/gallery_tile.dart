import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A component on the gallery index: a slip of paper, tilted a little,
/// holding its [picture], title, two lines of description and [chips].
/// Straightens and lifts on hover.
///
/// Mirrors `GalleryTile` in upstream `src/docs/content/components-gallery.tsx`.
class GalleryTile extends StatelessWidget {
  const GalleryTile({
    super.key,
    required this.title,
    required this.description,
    required this.picture,
    required this.tiltDegrees,
    this.chips = const [],
    required this.onPressed,
  });

  final String title;
  final String description;
  final Widget picture;
  final double tiltDegrees;
  final List<Widget> chips;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DocPressable(
      onPressed: onPressed,
      semanticLabel: title,
      builder: (context, highlighted) => AnimatedSlide(
        duration: InkMotion.of(context, InkMotion.hover),
        curve: InkMotion.easeOut,
        offset: switch (highlighted) {
          true => const Offset(0, -0.01),
          false => Offset.zero,
        },
        child: Paper(
          stock: StockName.slip,
          shadow: PaperShadow.slip,
          tiltDegrees: switch (highlighted) {
            true => 0,
            false => tiltDegrees,
          },
          seed: 'gallery:$title',
          padding: const EdgeInsets.fromLTRB(
            Spacing.d12,
            Spacing.d12,
            Spacing.d12,
            Spacing.d16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [
              picture,
              Text(
                title,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 24,
                  cssLineHeight: 1.1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 15,
                  cssLineHeight: 1.375,
                  color: theme.colors.inkSoft,
                ),
              ),
              if (chips.isNotEmpty)
                Wrap(
                  spacing: Spacing.d6,
                  runSpacing: Spacing.d6,
                  children: chips,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
