import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/folder/folder.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The panel a [FolderTab] opens onto: a [Paper] of the folder's stock,
/// square to the desk, at least 160 px tall, padded 32 px on top and 24 px
/// elsewhere ([padding] replaces that), with a fold across the top ([crease]). Only the open panel is
/// built; it is a Tab stop of its own.
///
/// Mirrors `FolderContent` in upstream `src/components/ui/folder.tsx`.
class FolderContent extends StatefulWidget {
  const FolderContent({
    super.key,
    required this.value,
    required this.child,
    this.crease = true,
    this.tilt = false,
    this.tiltDegrees,
    this.edge,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.seed,
    this.padding,
  });

  /// The space around [child]; upstream's `px-6 pt-8 pb-6` when null.
  final EdgeInsetsGeometry? padding;

  /// The [FolderTab] that opens it.
  final String value;

  /// What is in the folder.
  final Widget child;

  /// The fold across the top of the sheet.
  final bool crease;

  /// True turns the sheet a little; flat by default so the tabs stay square
  /// to the body.
  final bool tilt;

  /// A fixed tilt in degrees, used when [tilt] is true.
  final double? tiltDegrees;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// A fastener; none when null.
  final FastenerKind? fastener;

  /// The fastener's colour.
  final Accent? fastenerTone;

  /// The shadow.
  final PaperShadow shadow;

  /// Pins the sheet and the crease.
  final String? seed;

  @override
  State<FolderContent> createState() => _FolderContentState();
}

class _FolderContentState extends State<FolderContent> with InkSeed {
  static const double _tiltMax = 0.6;
  static const double _minHeight = Spacing.d160;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    Spacing.d24,
    Spacing.d32,
    Spacing.d24,
    Spacing.d24,
  );

  @override
  Widget build(BuildContext context) {
    final folder = FolderScope.maybeOf(context);
    if (folder?.value != widget.value) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final padding =
        widget.padding?.resolve(Directionality.of(context)) ?? _padding;
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, _tiltMax),
    };
    final params = FolderBodyParams(crease: widget.crease);
    return Semantics(
      container: true,
      role: SemanticsRole.tabPanel,
      child: Focus(
        child: Paper(
          stock: folder?.stock ?? StockName.kraft,
          rules: RuleName.none,
          edge: widget.edge,
          tilt: widget.tilt,
          tiltDegrees: degrees,
          tape: widget.tape,
          tapeKind: widget.tapeKind,
          fastener: widget.fastener,
          fastenerTone: widget.fastenerTone,
          shadow: widget.shadow,
          seed: seed,
          padding: padding,
          decor: switch (widget.crease) {
            false => null,
            true => Transform.rotate(
              angle: PaperInk.tilt(context, degrees),
              child: InkSurface(
                source: RecipeInkSource(
                  folderBodyRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: '$seed|decor',
                still: true,
              ),
            ),
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0.0, _minHeight - padding.vertical),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: theme.colors.ink),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                heightFactor: 1,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
