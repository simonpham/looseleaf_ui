import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// Folder tab recipe params.
///
/// Mirrors `FolderTabParams` in `src/lib/ink/recipes/folder-ink.ts`.
final class FolderTabParams {
  /// Params.
  const FolderTabParams({required this.stock, required this.disabled});

  /// The paper stock.
  final StockName stock;

  /// Draws only a dashed outline in the disabled layer.
  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'stock': stock.id, 'disabled': disabled};
}

/// Folder tab geometry: how far the selected tab overlaps the body, how
/// much lower the others sit, the side slant and the corner.
///
/// Mirrors `FOLDER_TAB` in `src/lib/ink/recipes/folder-ink.ts`.
const ({double overlap, double lower, double slant, double corner}) folderTab =
    (overlap: 4, lower: 4, slant: 9, corner: 6);

/// The outline of a [w]×[h] folder tab whose top sits at [top], running
/// [bottom] px past the foot, with a little jitter from [r].
///
/// Mirrors `tabPoints` in `src/lib/ink/recipes/folder-ink.ts`.
List<Pt> tabPoints(double w, double h, double top, Rng r, [double bottom = 0]) {
  final s = folderTab.slant;
  final c = folderTab.corner;
  double j() => r.gauss(0, 0.2);
  return [
    (j(), h + bottom),
    (j(), h),
    (s * 0.55 + j(), top + (h - top) * 0.5),
    (s - 1 + j(), top + c * 0.85),
    (s + 1.5, top + 1.2),
    (s + c, top + j()),
    (w / 2 + j(), top + j()),
    (w - s - c, top + j()),
    (w - s - 1.5, top + 1.2),
    (w - s + 1 + j(), top + c * 0.85),
    (w - s * 0.55 + j(), top + (h - top) * 0.5),
    (w + j(), h),
    (w + j(), h + bottom),
  ];
}

/// A folder tab: lower and shaded at rest, raised and joined to the body
/// when checked, a dashed outline when disabled, a sheen on hover.
///
/// Mirrors `folderTabRecipe` in `src/lib/ink/recipes/folder-ink.ts`.
final Recipe<FolderTabParams> folderTabRecipe = defineRecipe<FolderTabParams>(
  id: 'folder-tab',
  kind: 'folder-tab',
  layers: const [
    LayerName.rest,
    LayerName.checked,
    LayerName.disabled,
    LayerName.hover,
  ],
  pad: 6,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final stock = params.stock;
    final r = ink.next('tab');
    final seed = ink.seed;
    if (params.disabled) {
      ink.layer(LayerName.disabled, () {
        final d = polyD(tabPoints(w, h, folderTab.lower, r));
        ink.raw(
          pathTag(
            d,
            stroke: tok('pencil'),
            sw: 1,
            op: 0.7,
            extra: 'stroke-dasharray="3.4 3"',
          ),
          Material.under,
        );
      });
      return;
    }
    ink.layer(LayerName.rest, () {
      final top = folderTab.lower;
      final pts = tabPoints(w, h, top, r.fork('b'));
      final d = polyD(pts, true);
      final s =
          paperFill(seed, d, stock: stock, id: 'b') +
          pathTag(d, fill: tok('ink'), op: 0.12) +
          pathTag(
            'M${num10(w / 2)} ${num10(top)}H${num10(w)}V${num10(h)}H${num10(w / 2)}z',
            fill: tok('ink'),
            op: 0.05,
          ) +
          pathTag(
            polyD(pts.sublist(1, pts.length - 1)),
            stroke: tok('ink'),
            sw: 0.7,
            op: 0.34,
          ) +
          litEdge(polyD(pts.sublist(3, 8)), 0.5);
      ink
        ..raw(s, Material.under)
        ..grow(BBox(-1, top - 1, w + 1, h + 1));
    });
    ink.layer(LayerName.checked, () {
      final pts = tabPoints(w, h, 0, r.fork('f'), folderTab.overlap);
      final d = polyD(pts, true);
      final s =
          paperFill(seed, d, stock: stock, id: 'f') +
          pathTag(
            polyD(pts.sublist(1, pts.length - 1)),
            stroke: tok('ink'),
            sw: 0.75,
            op: 0.32,
          ) +
          litEdge(polyD(pts.sublist(3, 8)), 0.75);
      ink
        ..raw(s, Material.under)
        ..grow(BBox(-1, -1, w + 1, h + folderTab.overlap + 1));
    });
    if (!ctx.calm) {
      ink.layer(LayerName.hover, () {
        final pts = tabPoints(w, h, folderTab.lower, r.fork('h'));
        ink.raw(
          pathTag(polyD(pts, true), fill: tok('photo'), op: 0.3),
          Material.top,
        );
      });
    }
  },
);

/// Folder body recipe params.
///
/// Mirrors `FolderBodyParams` in `src/lib/ink/recipes/folder-ink.ts`.
final class FolderBodyParams {
  /// Params.
  const FolderBodyParams({required this.crease});

  /// A fold crease near the top.
  final bool crease;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'crease': crease};
}

/// A folder body's fold crease near the top edge.
///
/// Mirrors `folderBodyRecipe` in `src/lib/ink/recipes/folder-ink.ts`.
final Recipe<FolderBodyParams>
folderBodyRecipe = defineRecipe<FolderBodyParams>(
  id: 'folder-body',
  kind: 'folder',
  layers: const [LayerName.rest],
  pad: 2,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final r = ink.next('fold');
    ink.layer(LayerName.rest, () {
      if (!params.crease) return;
      final y = 11 + r.gauss(0, 0.5);
      final d =
          'M${num10(6)} ${num10(y)}L${num10(w / 2)} ${num10(y + r.gauss(0, 0.5))}'
          'L${num10(w - 6)} ${num10(y + r.gauss(0, 0.4))}';
      ink
        ..raw(
          pathTag(d, stroke: tok('ink'), sw: 0.8, op: 0.16) +
              pathTag(
                d,
                stroke: tok('photo'),
                sw: 1,
                op: 0.7,
                transform: 'translate(0 1.3)',
              ) +
              pathTag(
                'M0 ${num10(y)}H${num10(w)}V0H0z',
                fill: tok('ink'),
                op: 0.03,
              ),
          Material.top,
        )
        ..grow(BBox(0, 0, w, h));
    });
  },
);
