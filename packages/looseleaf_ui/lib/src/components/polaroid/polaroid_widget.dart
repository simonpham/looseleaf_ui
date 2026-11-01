import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An instant photograph: a white frame with a thick foot holding a square
/// [PolaroidImage] window and a [PolaroidCaption] in script, 10 px apart,
/// [width] wide, padded 14 px on the sides and top and 12 px at the foot.
/// Photographs turn a little more than paper (the photo stock's tilt).
/// Tape it, pin it or clip it like any [Paper].
///
/// ```dart
/// const Polaroid(
///   tape: PaperTape.top,
///   children: [
///     PolaroidImage(scene: PolaroidScene.hills, label: 'Hills and a tree'),
///     PolaroidCaption(Text('august, finally')),
///   ],
/// )
/// ```
///
/// Mirrors `Polaroid` in upstream `src/components/ui/polaroid.tsx`.
class Polaroid extends StatelessWidget {
  const Polaroid({
    super.key,
    this.width = defaultWidth,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.curl = false,
    this.seed,
    this.children = const [],
  });

  /// Upstream's `w-64`.
  static const double defaultWidth = 256;

  /// The frame's width.
  final double width;

  /// The edges; the photo stock's clean cut when null.
  final EdgeSpec? edge;

  /// False lays the photo flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within the photo stock's when null.
  final double? tiltDegrees;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// A clip, pin, staple or binder clip; none when null.
  final FastenerKind? fastener;

  /// The fastener's colour.
  final Accent? fastenerTone;

  /// The shadow.
  final PaperShadow shadow;

  /// A curled bottom-right corner.
  final bool curl;

  /// Pins the frame, the tilt, the tape and the fastener.
  final String? seed;

  /// The parts: a [PolaroidImage] and a [PolaroidCaption].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: SizedBox(
        width: width,
        child: Paper(
          stock: StockName.photo,
          rules: RuleName.none,
          edge: edge,
          tilt: tilt,
          tiltDegrees: tiltDegrees,
          tape: tape,
          tapeKind: tapeKind,
          fastener: fastener,
          fastenerTone: fastenerTone,
          shadow: shadow,
          curl: curl,
          seed: seed,
          padding: const EdgeInsets.fromLTRB(
            Spacing.d14,
            Spacing.d14,
            Spacing.d14,
            Spacing.d12,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: theme.colors.ink),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d10,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
