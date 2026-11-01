import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/doc_pressable.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A card linking to a page: a script title, a short description and
/// optional [meta] chips. Lifts a little on hover.
///
/// Mirrors `Tile` in upstream `src/docs/kit/Tile.tsx`.
class DocTile extends StatelessWidget {
  const DocTile({
    super.key,
    required this.title,
    this.description,
    this.meta = const [],
    required this.onPressed,
  });

  final String title;
  final String? description;
  final List<Widget> meta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DocPressable(
      onPressed: onPressed,
      semanticLabel: title,
      builder: (context, highlighted) => AnimatedSlide(
        duration: InkMotion.of(context, InkMotion.hover),
        curve: InkMotion.settle,
        offset: switch (highlighted) {
          true => const Offset(0, -0.015),
          false => Offset.zero,
        },
        child: Paper(
          stock: StockName.card,
          shadow: PaperShadow.card,
          seed: 'tile:$title',
          padding: const EdgeInsets.all(Spacing.d16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d6,
            children: [
              Text(
                title,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 24,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: switch (highlighted) {
                    true => theme.colors.inkYou,
                    false => theme.colors.ink,
                  },
                ),
              ),
              if (description case final text?)
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 15,
                    cssLineHeight: 1.375,
                    color: theme.colors.inkMuted,
                  ),
                ),
              if (meta.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.d6),
                  child: Wrap(spacing: Spacing.d6, children: meta),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
