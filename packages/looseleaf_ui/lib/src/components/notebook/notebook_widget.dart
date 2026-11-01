import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/notebook/notebook.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An open notebook on the desk: ruled paper with a red margin, bound with
/// a wire spiral, binder rings or a stab-stitched spine along the start
/// edge (mirrored right-to-left) or the top ([NotebookSide.top], a
/// reporter's pad on 30 px rules), its holes punched, [pages] more sheets
/// peeking out underneath.
///
/// Text is the hand face at 17 px on a 28 px rhythm (24 px when calm, 30
/// px bound on top), so words stand on the rules. [children] are
/// [NotebookPage]s and a [NotebookTurn]; with [value] or [defaultValue]
/// only the named page is shown, and the turn button over the [curl]
/// dog-ear turns to another. The notebook fills its parent's width unless
/// given a [width]; it turns at most 0.3°.
///
/// ```dart
/// Notebook(
///   curl: true,
///   defaultValue: 'mon',
///   children: const [
///     NotebookPage(value: 'mon', children: [
///       NotebookTitle(Text('Monday')),
///       Text('Rain on the window, three cups of tea.'),
///     ]),
///     NotebookPage(value: 'tue', children: [NotebookTitle(Text('Tuesday'))]),
///     NotebookTurn(to: 'tue', semanticLabel: 'Next: Tuesday'),
///   ],
/// )
/// ```
///
/// Mirrors `Notebook` in upstream `src/components/ui/notebook.tsx`.
class Notebook extends StatefulWidget {
  const Notebook({
    super.key,
    this.binding = NotebookBinding.spiral,
    this.side = NotebookSide.start,
    this.pages = 2,
    this.tone,
    this.curl = false,
    this.rules,
    this.stock = StockName.paper,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.width,
    this.minHeight = 0,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.seed,
    this.children = const [],
  }) : assert(pages >= 0 && pages <= 3, 'pages is 0 to 3');

  /// The binding.
  final NotebookBinding binding;

  /// The bound edge.
  final NotebookSide side;

  /// Sheets peeking out underneath, 0 to 3.
  final int pages;

  /// The wire's colour (the thread's for a stitched binding); steel (blue
  /// thread) when null.
  final Accent? tone;

  /// Folds the bottom-right corner over: a dog-ear for a [NotebookTurn].
  final bool curl;

  /// The printed rules; ruled, or pad when bound on top, when null.
  final RuleName? rules;

  /// The paper stock.
  final StockName stock;

  /// The open page, controlled.
  final String? value;

  /// The page open at first, when [value] is null.
  final String? defaultValue;

  /// Called with the page turned to.
  final ValueChanged<String>? onValueChange;

  /// The notebook's width; its parent's when null.
  final double? width;

  /// The notebook's least height.
  final double minHeight;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the notebook flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within 0.3° when null.
  final double? tiltDegrees;

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

  /// Pins the sheet, the binding and the tilt.
  final String? seed;

  /// The pages and the turn button.
  final List<Widget> children;

  @override
  State<Notebook> createState() => _NotebookState();
}

class _NotebookState extends State<Notebook> with InkSeed {
  static const double _tiltMax = 0.3;
  static const double _textSize = 17;

  late String? _inner = widget.defaultValue;

  void _turn(String page) {
    if (widget.value == null) setState(() => _inner = page);
    widget.onValueChange?.call(page);
  }

  double _lineHeight(LooseleafThemeData theme) =>
      switch ((widget.side, theme.density)) {
        (NotebookSide.top, _) => Spacing.d30,
        (_, LooseleafDensity.calm) => Spacing.d24,
        _ => Spacing.d28,
      };

  EdgeInsetsDirectional get _padding => switch (widget.side) {
    NotebookSide.top => const EdgeInsetsDirectional.fromSTEB(
      Spacing.d24,
      Spacing.d40,
      Spacing.d24,
      Spacing.d24,
    ),
    NotebookSide.start => const EdgeInsetsDirectional.fromSTEB(
      Spacing.d56,
      Spacing.d16,
      Spacing.d24,
      Spacing.d28,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, _tiltMax),
    };
    final decorated =
        widget.binding != NotebookBinding.none || widget.pages > 0;
    final params = NotebookParams(
      binding: widget.binding,
      side: widget.side,
      pages: widget.pages,
      tone: widget.tone,
      curl: widget.curl,
    );
    final line = _lineHeight(theme);
    final padding = _padding;
    final turns = widget.children.whereType<NotebookTurn>();
    final writing = [
      for (final child in widget.children)
        if (child is! NotebookTurn) child,
    ];
    final paper = Paper(
      stock: widget.stock,
      edge: widget.edge,
      tilt: widget.tilt,
      tiltDegrees: degrees,
      rules:
          widget.rules ??
          switch (widget.side) {
            NotebookSide.top => RuleName.pad,
            NotebookSide.start => RuleName.ruled,
          },
      mirrorRules: Directionality.of(context) == TextDirection.rtl,
      curl: widget.curl,
      tape: widget.tape,
      tapeKind: widget.tapeKind,
      fastener: widget.fastener,
      fastenerTone: widget.fastenerTone,
      shadow: widget.shadow,
      seed: seed,
      padding: padding,
      decor: switch (decorated) {
        false => null,
        true => Transform.rotate(
          angle: PaperInk.tilt(context, degrees),
          child: InkSurface(
            source: RecipeInkSource(
              notebookRecipe,
              params,
              json: params.toJson(),
            ),
            seed: '$seed|decor',
            still: true,
          ),
        ),
      },
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: _textSize,
          cssLineHeight: line / _textSize,
          color: theme.colors.ink,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(0, widget.minHeight - padding.vertical),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: writing,
          ),
        ),
      ),
    );
    return NotebookScope(
      value: widget.value ?? _inner,
      onTurn: _turn,
      side: widget.side,
      lineHeight: line,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = widget.width ?? constraints.maxWidth;
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: switch (width.isFinite) {
                true => width,
                false => 0,
              },
              maxWidth: width,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                paper,
                for (final turn in turns)
                  Positioned(right: 0, bottom: 0, child: turn),
              ],
            ),
          );
        },
      ),
    );
  }
}
