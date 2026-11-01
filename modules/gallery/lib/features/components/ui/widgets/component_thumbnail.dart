import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/models/models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A small live render of [example] on graph paper, inside a taped photo
/// frame; the component's initial when it has no example.
///
/// Mirrors `Picture` in upstream `src/docs/content/components-gallery.tsx`,
/// which shows a screenshot instead.
class ComponentThumbnail extends StatelessWidget {
  const ComponentThumbnail({
    super.key,
    required this.title,
    required this.example,
  });

  final String title;
  final GalleryExample? example;

  static const double _aspect = 16 / 10;
  static const Size _canvas = Size(448, 280);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final picture = switch (example) {
      null => Center(
        child: Text(
          title.characters.first,
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: 48,
            fontWeight: FontWeight.w700,
            color: theme.colors.inkMuted,
          ),
        ),
      ),
      final shown => FittedBox(
        fit: BoxFit.contain,
        child: SizedBox.fromSize(
          size: _canvas,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d24),
              child: shown.builder(),
            ),
          ),
        ),
      ),
    };
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Paper(
          stock: StockName.photo,
          tilt: false,
          shadow: PaperShadow.hair,
          tape: PaperTape.top,
          seed: 'thumb:$title',
          padding: const EdgeInsets.all(Spacing.d6),
          child: AspectRatio(
            aspectRatio: _aspect,
            child: ClipRect(
              child: ColoredBox(
                color: theme.colors.graph,
                child: TickerMode(enabled: false, child: picture),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
