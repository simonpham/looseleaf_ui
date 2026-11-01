import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// The sticky note's checkbox: its size, end inset and top.
///
/// Mirrors `STICKY_BOX` in `src/lib/ink/recipes/sticky-note-ink.ts`.
const ({double size, double inset, double top}) stickyBox = (
  size: 17,
  inset: 11,
  top: 10,
);

/// A sticky note's checkbox in the top end corner, ticked with a drawn-on
/// green felt check when checked.
///
/// Mirrors `stickyNoteRecipe` in `src/lib/ink/recipes/sticky-note-ink.ts`.
final Recipe<NoParams> stickyNoteRecipe = defineRecipe<NoParams>(
  id: 'sticky-note-decor',
  kind: 'sticky',
  layers: const [LayerName.rest, LayerName.checked],
  pad: 6,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final s = stickyBox.size;
    final x = w - stickyBox.inset - s;
    final y = stickyBox.top;
    void inMirror(void Function() fn) {
      if (ctx.dir == Dir.rtl) {
        ink.group(GroupAttrs(transform: mirrorTransform(w)), fn);
        return;
      }
      fn();
    }

    ink
      ..layer(
        LayerName.rest,
        () => inMirror(
          () => box(
            ink,
            x,
            y,
            s,
            s,
            pen: PenName.inkFine,
            corner: 2.5,
            opts: const StrokeOpts(alpha: 0.6),
          ),
        ),
      )
      ..layer(
        LayerName.checked,
        () => inMirror(
          () => reveal(
            ink,
            id: revealId(ctx.seed, 't'),
            lines: checkLines(ink.next('tick'), x + 2, y, s + 1),
            pen: PenName.greenfelt,
            box: Box(w, h),
            revealWidth: 7,
            width: 1.15,
          ),
        ),
      );
  },
);
