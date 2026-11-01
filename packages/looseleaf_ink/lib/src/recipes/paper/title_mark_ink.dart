import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// How a paper set title is marked.
///
/// Mirrors `TitleMark` in `src/lib/ink/recipes/paper-set-ink.ts`.
enum TitleMark { single, double, wavy, highlight }

/// The pen of a title mark.
///
/// Mirrors `TitleMarkParams['tone']` in `src/lib/ink/recipes/paper-set-ink.ts`.
enum TitleMarkTone {
  ink(PenName.ink),
  you(PenName.blue),
  red(PenName.redfelt),
  marker(PenName.terracotta);

  const TitleMarkTone(this.pen);

  /// The pen it draws with (`MARK_PEN`).
  final PenName pen;
}

/// Title mark recipe params.
///
/// Mirrors `TitleMarkParams` in `src/lib/ink/recipes/paper-set-ink.ts`.
final class TitleMarkParams {
  /// Params.
  const TitleMarkParams({required this.kind, this.tone});

  /// The mark.
  final TitleMark kind;

  /// The pen; [TitleMarkTone.ink] when null.
  final TitleMarkTone? tone;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    if (tone case final TitleMarkTone t) 'tone': t.name,
  };
}

/// A title underline (single, double or wavy) or a highlighter swipe; a
/// plain pencil underline when calm.
///
/// Mirrors `titleMarkRecipe` in `src/lib/ink/recipes/paper-set-ink.ts`.
final Recipe<TitleMarkParams> titleMarkRecipe = defineRecipe<TitleMarkParams>(
  id: 'paper-set-title-mark',
  kind: 'mark',
  layers: const [LayerName.rest],
  pad: 10,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ink.layer(LayerName.rest, () {
      final underlineKind = switch (params.kind) {
        TitleMark.single => UnderlineKind.single,
        TitleMark.double => UnderlineKind.double,
        TitleMark.wavy => UnderlineKind.wavy,
        TitleMark.highlight => null,
      };
      if (underlineKind == null) {
        highlight(ink, -3, h * 0.46, w + 6, h * 0.42, pen: PenName.hi);
        return;
      }
      final y = h - 4;
      if (ctx.calm) {
        underline(
          ink,
          0,
          y,
          w,
          kind: UnderlineKind.single,
          pen: PenName.pencilFine,
        );
        return;
      }
      underline(
        ink,
        -2,
        y,
        w + 4,
        kind: underlineKind,
        pen: (params.tone ?? TitleMarkTone.ink).pen,
      );
    });
  },
);
