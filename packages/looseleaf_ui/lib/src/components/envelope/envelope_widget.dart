import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/envelope/envelope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// An envelope on the desk with a [stamp], a [postmark] and address lines,
/// that opens: the flap stands up behind and an [EnvelopeLetter] slides
/// out from between the panels, the [EnvelopeFront] hiding its foot. As
/// wide as it may up to [maxWidth], 8 : 5. Open, it makes room above itself
/// for the flap and the letter; hovering lifts the flap a sliver.
///
/// Controlled with [open] and [onOpenChange], or left to itself from
/// [defaultOpen]. [openOnHover] also opens it while a mouse is over it.
/// Put the front before the letter in [children]: Tab goes from the
/// trigger to the letter, which is always drawn behind the front.
///
/// ```dart
/// Envelope(
///   children: [
///     EnvelopeFront(children: [
///       EnvelopeSender(child: Text('The Stationer')),
///       EnvelopeAddress(children: [Text('Ada Lovelace'), Text('Paris')]),
///       EnvelopeTrigger(label: 'Read the letter from The Stationer'),
///     ]),
///     EnvelopeLetter(child: Text('Dear Ada,')),
///   ],
/// )
/// ```
///
/// Mirrors `Envelope` in upstream `src/components/ui/envelope.tsx`.
class Envelope extends StatefulWidget {
  const Envelope({
    super.key,
    this.children = const [],
    this.stock = StockName.kraft,
    this.stamp = Accent.tomato,
    this.postmark = true,
    this.airmail = false,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.openOnHover = false,
    this.disabled = false,
    this.tilt = true,
    this.tiltDegrees,
    this.maxWidth = defaultMaxWidth,
    this.seed,
    this.forcedStates = const {},
  });

  /// Upstream's `max-w-sm`.
  static const double defaultMaxWidth = 384;

  /// How much room an open envelope makes above itself, as a share of its
  /// width (upstream's `h-[31cqw]`).
  static const double openRoom = 0.31;

  /// An [EnvelopeFront], then an [EnvelopeLetter].
  final List<Widget> children;

  /// What it is made of: kraft (manila), paper, index card, a sticky…
  final StockName stock;

  /// The postage stamp's colour; no stamp when null.
  final Accent? stamp;

  /// Cancels the stamp with rings and wavy lines (only with a [stamp]).
  final bool postmark;

  /// A border of slanted red and blue stripes.
  final bool airmail;

  /// Whether the letter is out; null leaves it to the envelope.
  final bool? open;

  /// Whether an uncontrolled envelope starts open.
  final bool defaultOpen;

  /// Called with the next open state.
  final ValueChanged<bool>? onOpenChange;

  /// Also opens while a mouse is over it and closes when it leaves, unless
  /// it was opened by a press or focus is in the letter. Touch never opens
  /// it on hover.
  final bool openOnHover;

  /// Sealed: the trigger is disabled and hovering opens nothing.
  final bool disabled;

  /// False lays it flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within 1.1° when null.
  final double? tiltDegrees;

  /// The largest width.
  final double maxWidth;

  /// Pins the paper, the stamp, the flap and the tilt.
  final String? seed;

  /// States the back panel shows whatever the input (`hovered`): for state
  /// grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Envelope> createState() => _EnvelopeState();
}

class _EnvelopeState extends State<Envelope> with InkSeed {
  static const double _tiltMax = 1.1;

  late bool _inner = widget.defaultOpen;
  bool _hovered = false;
  bool _hoverOpened = false;
  final FocusScopeNode _letterFocus = FocusScopeNode(
    debugLabel: 'EnvelopeLetter',
  );

  bool get _open => widget.open ?? _inner;

  void _setOpen(bool open) {
    if (widget.open == null) setState(() => _inner = open);
    widget.onOpenChange?.call(open);
  }

  void _toggle() {
    if (_open && _hoverOpened) {
      _hoverOpened = false;
      return;
    }
    _hoverOpened = false;
    _setOpen(!_open);
  }

  void _enter(PointerEnterEvent event) {
    setState(() => _hovered = true);
    if (!widget.openOnHover || widget.disabled || _open) return;
    if (event.kind != PointerDeviceKind.mouse) return;
    _hoverOpened = true;
    _setOpen(true);
  }

  void _exit(PointerExitEvent event) {
    setState(() => _hovered = false);
    if (!widget.openOnHover || event.kind != PointerDeviceKind.mouse) return;
    if (!_hoverOpened) return;
    _hoverOpened = false;
    if (_letterFocus.hasFocus) return;
    _setOpen(false);
  }

  @override
  void dispose() {
    _letterFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, _tiltMax),
    };
    final open = _open;
    final tilt = PaperInk.tilt(context, degrees);
    final params = EnvelopeBackParams(stock: widget.stock);
    final states = {
      ...widget.forcedStates,
      if (_hovered) InkState.hovered,
      if (open) InkState.open,
    };
    final letters = [
      for (final child in widget.children)
        if (child is EnvelopeLetter) child,
    ];
    final others = [
      for (final child in widget.children)
        if (child is! EnvelopeLetter) child,
    ];
    return EnvelopeScope(
      stock: widget.stock,
      stamp: widget.stamp,
      postmark: widget.postmark && widget.stamp != null,
      airmail: widget.airmail,
      seed: seed,
      tilt: tilt,
      open: open,
      disabled: widget.disabled,
      toggle: _toggle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(widget.maxWidth, constraints.maxWidth);
          final height = width * 5 / 8;
          return SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    end: switch (open) {
                      true => width * Envelope.openRoom,
                      false => 0,
                    },
                  ),
                  duration: InkMotion.of(context, InkMotion.sheet),
                  curve: InkMotion.settle,
                  builder: (context, room, _) =>
                      SizedBox(height: math.max(0, room)),
                ),
                MouseRegion(
                  onEnter: _enter,
                  onExit: _exit,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: FocusTraversalGroup(
                      policy: OrderedTraversalPolicy(),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: ExcludeSemantics(
                              child: Transform.rotate(
                                angle: tilt,
                                child: InkSurface(
                                  source: RecipeInkSource(
                                    envelopeBackRecipe,
                                    params,
                                    json: params.toJson(),
                                  ),
                                  seed: seed,
                                  states: states,
                                  still: true,
                                ),
                              ),
                            ),
                          ),
                          for (final letter in letters)
                            Positioned(
                              left: width * 0.05,
                              right: width * 0.05,
                              bottom: height * 0.09,
                              height: height * 0.86,
                              child: FocusTraversalOrder(
                                order: const NumericFocusOrder(1),
                                child: FocusScope(
                                  node: _letterFocus,
                                  child: letter,
                                ),
                              ),
                            ),
                          for (final other in others)
                            Positioned.fill(
                              child: FocusTraversalOrder(
                                order: const NumericFocusOrder(0),
                                child: other,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
