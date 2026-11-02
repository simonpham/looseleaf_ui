import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/page/page.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A page of writing: a [Paper] holding a centred column of [children]
/// ([PageHeader], [PageContent], [PageFooter]) 24 px apart, at most
/// [width] wide (as wide as it may up to that, and at least as tall as
/// its parent asks), padded 24 × 32 px (40 px from the `sm` breakpoint,
/// more on the punched edge); [padding] replaces that.
///
/// [holes] punches three holes down the start edge or two across the top
/// (the desk shows through), [reinforced] rings them, [stain] adds a coffee
/// ring, [torn] tears the top, bottom or both edges off a pad. The decor
/// tilts with the sheet, at most 0.35°.
///
/// ```dart
/// const PaperPage(
///   seed: 'field-notes',
///   children: [
///     PageHeader(children: [PageTitle(Text('Field notes'))]),
///     PageContent(children: [Text('Tuesday.')]),
///   ],
/// )
/// ```
///
/// Named `PaperPage` because Flutter's widgets library has a `Page`.
///
/// Mirrors `Page` in upstream `src/components/ui/page.tsx`.
class PaperPage extends StatefulWidget {
  const PaperPage({
    super.key,
    this.width = PageWidth.md,
    this.holes = PageHoles.none,
    this.reinforced = false,
    this.stain = false,
    this.torn,
    this.stock = StockName.paper,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.rules,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.seed,
    this.padding,
    required this.children,
  });

  /// Upstream's `sm` breakpoint: wider viewports pad more.
  static const double wideFrom = 640;

  /// The largest width.
  final PageWidth width;

  /// Punched holes.
  final PageHoles holes;

  /// Gummed rings around the holes.
  final bool reinforced;

  /// A coffee ring near the bottom end.
  final bool stain;

  /// Torn edges; [edge] wins when set.
  final PageTorn? torn;

  /// The paper stock.
  final StockName stock;

  /// The edges; [torn]'s, else the stock's, when null.
  final EdgeSpec? edge;

  /// False lays the page flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within 0.35° when null.
  final double? tiltDegrees;

  /// The printed rules; the stock's when null.
  final RuleName? rules;

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

  /// Pins the sheet, the decor and the tilt.
  final String? seed;

  /// The parts.
  final List<Widget> children;

  /// The space around the column; upstream's `px-6 py-8 sm:px-10 sm:py-10`
  /// (plus room for the holes) when null.
  final EdgeInsetsGeometry? padding;

  @override
  State<PaperPage> createState() => _PageState();
}

class _PageState extends State<PaperPage> with InkSeed {
  static const double _tiltMax = 0.35;

  EdgeSpec? get _edge =>
      widget.edge ??
      switch (widget.torn) {
        null => null,
        PageTorn.top => const EdgeSpec(top: EdgeKind.torn),
        PageTorn.bottom => const EdgeSpec(bottom: EdgeKind.torn),
        PageTorn.both => const EdgeSpec(
          top: EdgeKind.torn,
          bottom: EdgeKind.torn,
        ),
      };

  EdgeInsetsDirectional _padding(bool wide) {
    final side = switch (wide) {
      true => Spacing.d40,
      false => Spacing.d24,
    };
    final block = switch (wide) {
      true => Spacing.d40,
      false => Spacing.d32,
    };
    return EdgeInsetsDirectional.fromSTEB(
      switch ((widget.holes, wide)) {
        (PageHoles.start, true) => Spacing.d68,
        (PageHoles.start, false) => Spacing.d56,
        _ => side,
      },
      switch ((widget.holes, wide)) {
        (PageHoles.top, true) => Spacing.d64,
        (PageHoles.top, false) => Spacing.d56,
        _ => block,
      },
      side,
      block,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, _tiltMax),
    };
    final wide =
        (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= PaperPage.wideFrom;
    final decorated = widget.holes != PageHoles.none || widget.stain;
    final params = PageParams(
      holes: widget.holes,
      reinforce: widget.reinforced,
      stain: widget.stain,
    );
    final content = Padding(
      padding: widget.padding ?? _padding(wide),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: theme.colors.ink),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d24,
          children: widget.children,
        ),
      ),
    );
    final page = Paper(
      stock: widget.stock,
      edge: _edge,
      tilt: widget.tilt,
      tiltDegrees: degrees,
      rules: widget.rules,
      mirrorRules: theme.textDirection == TextDirection.rtl,
      tape: widget.tape,
      tapeKind: widget.tapeKind,
      fastener: widget.fastener,
      fastenerTone: widget.fastenerTone,
      shadow: widget.shadow,
      seed: seed,
      decor: switch (decorated) {
        false => null,
        true => Transform.rotate(
          angle: PaperInk.tilt(context, degrees),
          child: InkSurface(
            source: RecipeInkSource(pageRecipe, params, json: params.toJson()),
            seed: '$seed|decor',
            still: true,
          ),
        ),
      },
      child: content,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(widget.width.maxWidth, constraints.maxWidth);
        return Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: switch (width.isFinite) {
                true => width,
                false => 0,
              },
              maxWidth: width,
              minHeight: constraints.minHeight,
            ),
            child: page,
          ),
        );
      },
    );
  }
}
