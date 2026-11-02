import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sticky_note/sticky_note.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A square of coloured paper with a gum band, written in marker script:
/// [children] ([StickyNoteTitle], [StickyNoteContent], [StickyNoteFooter])
/// stack 4 px apart under the band, on a note [width] wide and at least
/// [minHeight] tall ([height] fixes it; a [minHeight] under the padding,
/// upstream's `min-h-0`, lets the content set the height). [padding]
/// replaces the 16 px sides, 24 px top (32 with a tick box) and 16 px foot.
/// It turns up to 1.6°, and can curl
/// a corner, hang from a pin or a strip of tape.
///
/// Passing [done] adds a pencil tick box in the top end corner: `true`
/// writes a green felt tick (drawn on when it changes, whole when the note
/// loads done) and strikes the content through. With [onDoneChange] the box
/// is a real checkbox named [doneLabel]; without it a done note tells
/// screen readers "[doneLabel]." before its content.
///
/// ```dart
/// StickyNote(
///   color: StickyColor.pink,
///   curl: true,
///   fastener: FastenerKind.pin,
///   done: done,
///   onDoneChange: (value) => setState(() => done = value),
///   children: const [
///     StickyNoteTitle(Text('urgent')),
///     StickyNoteContent(Text('call mum before six')),
///     StickyNoteFooter(Text('from Ada')),
///   ],
/// )
/// ```
///
/// Mirrors `StickyNote` in upstream `src/components/ui/sticky-note.tsx`.
class StickyNote extends StatefulWidget {
  const StickyNote({
    super.key,
    this.color = StickyColor.yellow,
    this.done,
    this.onDoneChange,
    this.doneLabel = 'Done',
    this.width = defaultWidth,
    this.minHeight = defaultMinHeight,
    this.height,
    this.padding,
    this.curl = false,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.seed,
    this.focusNode,
    this.forcedStates = const {},
    this.children = const [],
  });

  /// Upstream's `w-44`.
  static const double defaultWidth = 176;

  /// Upstream's `min-h-40`.
  static const double defaultMinHeight = 160;

  /// The pad.
  final StickyColor color;

  /// Null for a plain note; otherwise the tick box's state.
  final bool? done;

  /// Makes the tick box a checkbox asking for the opposite of [done].
  final ValueChanged<bool>? onDoneChange;

  /// The tick box's name, and what a done note says to screen readers.
  final String doneLabel;

  /// The note's width.
  final double width;

  /// The note's least height; content past it grows the note.
  final double minHeight;

  /// A fixed height, overriding [minHeight].
  final double? height;

  /// The space around the parts; upstream's `px-4 pt-6 pb-4` (`pt-8` with
  /// a tick box) when null.
  final EdgeInsetsGeometry? padding;

  /// Lifts the bottom-right corner.
  final bool curl;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the note flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within 1.6° when null.
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

  /// Pins the sheet, the tick and the tilt.
  final String? seed;

  /// The tick box's focus node, when it is a checkbox.
  final FocusNode? focusNode;

  /// States the tick box shows whatever the input: for goldens.
  final Set<InkState> forcedStates;

  /// The parts.
  final List<Widget> children;

  @override
  State<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends State<StickyNote> with InkSeed {
  static const double _tiltMax = 1.6;
  static const _checkInset = EdgeInsetsDirectional.only(end: 3.5, top: 2.5);

  bool _touched = false;

  @override
  void didUpdateWidget(StickyNote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.done != widget.done) _touched = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, _tiltMax),
    };
    final done = widget.done;
    final onDoneChange = widget.onDoneChange;
    const params = NoParams();
    final padding =
        widget.padding?.resolve(Directionality.of(context)) ??
        EdgeInsets.fromLTRB(
          Spacing.d16,
          switch (done) {
            null => Spacing.d24,
            _ => Spacing.d32,
          },
          Spacing.d16,
          Spacing.d16,
        );
    final innerWidth = math.max(0.0, widget.width - padding.horizontal);
    final column = DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.script,
        cssSize: 21.6,
        cssLineHeight: 1.15,
        color: theme.colors.ink,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d4,
        children: widget.children,
      ),
    );
    final spoken = switch (done == true && onDoneChange == null) {
      true => Semantics(
        container: true,
        label: '${widget.doneLabel}.',
        child: column,
      ),
      false => column,
    };
    final height = widget.height;
    final paper = Paper(
      stock: widget.color.stock,
      edge: widget.edge,
      tilt: widget.tilt,
      tiltDegrees: degrees,
      tape: widget.tape,
      tapeKind: widget.tapeKind,
      fastener: widget.fastener,
      fastenerTone: widget.fastenerTone,
      shadow: widget.shadow,
      curl: widget.curl,
      seed: seed,
      padding: padding,
      decor: switch (done) {
        null => null,
        final ticked => Transform.rotate(
          angle: PaperInk.tilt(context, degrees),
          child: InkSurface(
            source: RecipeInkSource(
              stickyNoteRecipe,
              params,
              json: params.toJson(),
            ),
            seed: '$seed|decor',
            states: {if (ticked) InkState.checked},
            drawOn: _touched,
            still: true,
          ),
        ),
      },
      child: switch (height) {
        null => ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: innerWidth,
            minHeight: math.max(0.0, widget.minHeight - padding.vertical),
          ),
          child: IntrinsicHeight(child: spoken),
        ),
        _ => SizedBox(width: innerWidth, child: spoken),
      },
    );
    final note = SizedBox(
      width: widget.width,
      height: height,
      child: StickyNoteScope(done: done ?? false, child: paper),
    );
    if (done == null || onDoneChange == null) return note;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        note,
        PositionedDirectional(
          top: _checkInset.top,
          end: _checkInset.end,
          child: StickyNoteCheck(
            value: done,
            onChanged: onDoneChange,
            label: widget.doneLabel,
            focusNode: widget.focusNode,
            forcedStates: widget.forcedStates,
          ),
        ),
      ],
    );
  }
}
