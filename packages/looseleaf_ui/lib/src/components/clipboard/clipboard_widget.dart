import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/clipboard/clipboard_clip.dart';
import 'package:looseleaf_ui/src/components/clipboard/clipboard_scope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A board with a spring clip holding a sheet of paper. The board is one
/// drawn sheet (hardboard with the grain of its fiber, or plastic in a
/// [tone]) that turns a seeded hair (within 1.2°, flat when calm) and casts
/// its own shadow; the chrome clip is drawn over the paper, upright, and
/// hides when calm.
///
/// [children] (usually one [ClipboardPaper]) stack in a column as wide as
/// the parent allows up to [maxWidth], inside a 24 px rim, the first one
/// tucked under the clip 32 px from the top. With [minHeight] the board is
/// at least that tall and the paper grows to fill it.
///
/// ```dart
/// const InkClipboard(
///   tone: Accent.teal,
///   children: [ClipboardPaper(child: Text('Visitors'))],
/// )
/// ```
///
/// Mirrors `Clipboard` in upstream `src/components/ui/clipboard.tsx`.
class InkClipboard extends StatefulWidget {
  const InkClipboard({
    super.key,
    this.tone,
    this.maxWidth = defaultMaxWidth,
    this.minHeight,
    this.tilt = true,
    this.tiltDegrees,
    this.seed,
    this.children = const [],
  });

  /// Upstream's `max-w-md`.
  static const double defaultMaxWidth = 448;

  /// The largest seeded turn, in degrees.
  static const double tiltMax = 1.2;

  /// Upstream's `pt-14` less the paper's `-mt-6`: the paper's top edge.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    Spacing.d24,
    Spacing.d32,
    Spacing.d24,
    Spacing.d24,
  );

  /// A plastic board in this colour; hardboard when null.
  final Accent? tone;

  /// The largest width.
  final double maxWidth;

  /// The board's least height; the paper grows into it. Sized to the
  /// paper when null.
  final double? minHeight;

  /// False lays the board flat.
  final bool tilt;

  /// A fixed turn in degrees, clamped to the tilt budget; seeded within
  /// 1.2° when null.
  final double? tiltDegrees;

  /// Pins the board, the clip and the turn.
  final String? seed;

  /// What the clip holds.
  final List<Widget> children;

  @override
  State<InkClipboard> createState() => _ClipboardState();
}

class _ClipboardState extends State<InkClipboard> with InkSeed {
  Widget _column() {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.children,
    );
    final minHeight = widget.minHeight;
    if (minHeight == null) return column;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: math.max(0, minHeight - InkClipboard.padding.vertical),
      ),
      child: IntrinsicHeight(child: column),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, InkClipboard.tiltMax),
    };
    final params = ClipboardBoardParams(tone: widget.tone);
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: switch (constraints.maxWidth.isFinite) {
          true => math.min(widget.maxWidth, constraints.maxWidth),
          false => widget.maxWidth,
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Transform.rotate(
                angle: PaperInk.tilt(context, degrees),
                child: InkSurface(
                  source: RecipeInkSource(
                    clipboardBoardRecipe,
                    params,
                    json: params.toJson(),
                  ),
                  seed: seed,
                  still: true,
                ),
              ),
            ),
            Padding(
              padding: InkClipboard.padding,
              child: ClipboardScope(
                fills: widget.minHeight != null,
                child: _column(),
              ),
            ),
            if (!PaperInk.calm(theme))
              Positioned(
                top: Spacing.d12,
                left: 0,
                right: 0,
                child: Center(
                  child: ExcludeSemantics(
                    child: ClipboardClip(seed: '$seed|clip'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
