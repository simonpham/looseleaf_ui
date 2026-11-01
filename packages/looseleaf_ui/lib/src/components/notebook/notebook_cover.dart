import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The cover of a closed notebook, for a shelf: cloth over board in any
/// stationery [tone] (black when null), a darker stitched spine on the
/// start edge and an elastic [band] round the end, drawn as one sheet with
/// its shadow and a seeded turn under 1.4°. [width] × [height] (11 × 15
/// rem by default). [child], usually a [NotebookCoverLabel], sits 52 px
/// down, centred clear of the spine and the band.
///
/// ```dart
/// const NotebookCover(
///   tone: Accent.teal,
///   child: NotebookCoverLabel(Text('Recipes')),
/// )
/// ```
///
/// Mirrors `NotebookCover` in upstream `src/components/ui/notebook.tsx`.
class NotebookCover extends StatefulWidget {
  const NotebookCover({
    super.key,
    this.tone = Accent.tomato,
    this.band = true,
    this.width = defaultWidth,
    this.height = defaultHeight,
    this.tilt = true,
    this.tiltDegrees,
    this.seed,
    this.semanticLabel,
    this.child,
  });

  /// Upstream's `w-44`.
  static const double defaultWidth = 176;

  /// Upstream's `h-60`.
  static const double defaultHeight = 240;

  /// The cloth; black (`ink`) when null.
  final Accent? tone;

  /// The elastic band.
  final bool band;

  /// The cover's width.
  final double width;

  /// The cover's height.
  final double height;

  /// False lays the cover flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within 1.4° when null.
  final double? tiltDegrees;

  /// Pins the cloth, the stitching and the tilt.
  final String? seed;

  /// Names the notebook as a group ("Field notes notebook").
  final String? semanticLabel;

  /// The label.
  final Widget? child;

  @override
  State<NotebookCover> createState() => _NotebookCoverState();
}

class _NotebookCoverState extends State<NotebookCover> with InkSeed {
  static const double _tiltMax = 1.4;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, _tiltMax),
    };
    final params = NotebookCoverParams(tone: widget.tone, band: widget.band);
    final endInset = math.max(Spacing.d22, widget.width * 0.15) + Spacing.d6;
    return Semantics(
      container: widget.semanticLabel != null,
      label: widget.semanticLabel,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.rotate(
              angle: PaperInk.tilt(context, degrees),
              child: InkSurface(
                source: RecipeInkSource(
                  notebookCoverRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: seed,
                still: true,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: Spacing.d52,
                start: Spacing.d20,
                end: endInset,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: theme.colors.ink),
                child: Column(children: [?widget.child]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
