import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/peel_corner/peel_corner_flap.dart';
import 'package:looseleaf_ui/src/components/peel_corner/peel_corner_page.dart';
import 'package:looseleaf_ui/src/components/peel_corner/peel_corner_scope.dart';
import 'package:looseleaf_ui/src/components/peel_corner/peel_corner_under.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A page with a corner you can peel back to see the sheet underneath: a
/// voucher code, a hidden note.
///
/// Put a [PeelCornerPage] and a [PeelCornerUnder] in [children]. The corner
/// rests slightly curled, lifts when a pointer hovers it, follows a drag
/// and opens or springs back when let go (past 62 %); a tap, Enter or
/// Space toggles it. The corner button is a 56 px square over the page's
/// corner, named [label]. Uncontrolled it keeps its own state
/// ([defaultPeeled]); pass [peeled] and [onPeeledChange] to control it: a
/// declined change eases back. Where motion is reduced it jumps instead of
/// easing.
///
/// ```dart
/// SizedBox(
///   width: 320,
///   child: PeelCorner(
///     label: 'Reveal the voucher code',
///     children: [
///       PeelCornerPage(child: Text('Spring sale')),
///       PeelCornerUnder(child: Text('SAVE10')),
///     ],
///   ),
/// )
/// ```
///
/// Mirrors `PeelCorner` in upstream `src/components/ui/peel-corner.tsx`.
class PeelCorner extends StatefulWidget {
  const PeelCorner({
    super.key,
    required this.children,
    this.peeled,
    this.defaultPeeled = false,
    this.onPeeledChange,
    this.size = peelUnit,
    this.corner = PeelCornerSide.bottomRight,
    this.back = PaintKey.paper,
    this.label = 'Peel back the corner',
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The curl's scale at rest.
  static const double rest = 0.2;

  /// The curl's scale while a pointer hovers the closed corner.
  static const double peek = 0.42;

  /// The curl's scale when open.
  static const double open = 1;

  /// The furthest a drag can pull the curl.
  static const double max = 1.3;

  /// Where a let-go drag opens rather than springs back.
  static const double openAt = 0.62;

  /// The corner button's side.
  static const double hit = 56;

  /// How far a press must move to count as a drag.
  static const double dragSlop = 4;

  /// `260ms` with a cubic ease-out.
  static const Duration ease = Duration(milliseconds: 260);

  /// The [PeelCornerPage], the [PeelCornerUnder], anything else.
  final List<Widget> children;

  /// Whether the corner is open; null leaves it uncontrolled.
  final bool? peeled;

  /// The first state of an uncontrolled corner.
  final bool defaultPeeled;

  /// Called with the state the corner is going to.
  final ValueChanged<bool>? onPeeledChange;

  /// The flap's size when fully open.
  final double size;

  /// Which bottom corner peels.
  final PeelCornerSide corner;

  /// The paint of the flap's back.
  final PaintKey back;

  /// The corner button's name: say what it reveals.
  final String label;

  /// Pins the flap and the focus ring.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<PeelCorner> createState() => _PeelCornerState();
}

class _PeelCornerState extends State<PeelCorner>
    with SingleTickerProviderStateMixin, InkSeed {
  late bool _inner = widget.defaultPeeled;
  late final AnimationController _k;
  late final ValueNotifier<double> _peel = ValueNotifier(
    _k.value * widget.size,
  );
  late bool _settled;
  final GlobalKey _root = GlobalKey();
  ({int pointer, Offset start, bool moved})? _drag;
  bool _dragged = false;

  bool get _open => widget.peeled ?? _inner;

  @override
  void initState() {
    super.initState();
    _k = AnimationController.unbounded(
      vsync: this,
      value: _rest(_open),
    )..addListener(_paint);
    _settled = _open;
    _paint();
  }

  static double _rest(bool open) => switch (open) {
    true => PeelCorner.open,
    false => PeelCorner.rest,
  };

  void _paint() => _peel.value = _k.value * widget.size;

  void _tween(double to) {
    _k.stop();
    if (InkMotion.reducedIn(context) || (to - _k.value).abs() < 0.005) {
      _k.value = to;
      return;
    }
    _k.animateTo(to, duration: PeelCorner.ease, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(PeelCorner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) _paint();
    if (_settled == _open) return;
    _settled = _open;
    _tween(_rest(_open));
  }

  @override
  void dispose() {
    _k.dispose();
    _peel.dispose();
    super.dispose();
  }

  void _set(bool value) {
    _settled = value;
    if (widget.peeled == null) setState(() => _inner = value);
    widget.onPeeledChange?.call(value);
    _tween(_rest(value));
    if (widget.peeled == null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _open == value) return;
      _settled = _open;
      _tween(_rest(_open));
    });
  }

  double _pull(Offset global) {
    final box = _root.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return PeelCorner.rest;
    final local = box.globalToLocal(global);
    final fromBottom = box.size.height - local.dy;
    final p = switch (widget.corner) {
      PeelCornerSide.bottomRight =>
        (box.size.width - local.dx + fromBottom) / 2,
      PeelCornerSide.bottomLeft => (local.dx + fromBottom) / 2,
    };
    return (p / widget.size).clamp(0.05, PeelCorner.max);
  }

  void _down(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;
    _dragged = false;
    _drag = (pointer: event.pointer, start: event.position, moved: false);
    _k.stop();
  }

  void _move(PointerMoveEvent event) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    final moved =
        drag.moved ||
        (event.position - drag.start).distance > PeelCorner.dragSlop;
    _drag = (pointer: drag.pointer, start: drag.start, moved: moved);
    if (moved) _k.value = _pull(event.position);
  }

  void _up(PointerUpEvent event) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    _drag = null;
    if (!drag.moved) return;
    _dragged = true;
    final value = _k.value >= PeelCorner.openAt;
    if (value != _open) {
      _set(value);
      return;
    }
    _tween(_rest(value));
  }

  void _cancel(PointerCancelEvent event) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    _drag = null;
    _tween(_rest(_open));
  }

  void _activate() {
    if (_dragged) {
      _dragged = false;
      return;
    }
    _set(!_open);
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.corner == PeelCornerSide.bottomLeft;
    final under = [
      for (final child in widget.children)
        if (child is PeelCornerUnder) Positioned.fill(child: child),
    ];
    final rest = [
      for (final child in widget.children)
        if (child is! PeelCornerUnder) child,
    ];
    return PeelCornerScope(
      open: _open,
      corner: widget.corner,
      peel: _peel,
      child: Stack(
        key: _root,
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          ...under,
          ...rest,
          Positioned(
            bottom: 0,
            left: switch (left) {
              true => 0,
              false => null,
            },
            right: switch (left) {
              true => null,
              false => 0,
            },
            child: PeelCornerFlap(
              size: widget.size,
              back: widget.back,
              seed: widget.seed,
            ),
          ),
          Positioned(
            bottom: 0,
            left: switch (left) {
              true => 0,
              false => null,
            },
            right: switch (left) {
              true => null,
              false => 0,
            },
            child: _trigger(),
          ),
        ],
      ),
    );
  }

  Widget _trigger() {
    final hitSeed = switch (widget.seed) {
      final seed? => '$seed|hit',
      null => null,
    };
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      expanded: _open,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) {
          if (_open || _drag != null) return;
          _tween(PeelCorner.peek);
        },
        onExit: (_) {
          if (_drag != null) return;
          _tween(_rest(_open));
        },
        child: Listener(
          onPointerDown: _down,
          onPointerMove: _move,
          onPointerUp: _up,
          onPointerCancel: _cancel,
          child: InkInteraction(
            onActivate: _activate,
            states: widget.forcedStates,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            mouseCursor: switch (_drag) {
              null => SystemMouseCursors.grab,
              _ => SystemMouseCursors.grabbing,
            },
            builder: (context, states) => InkSurface(
              source: RecipeInkSource(
                peelTriggerRecipe,
                const NoParams(),
                json: const NoParams().toJson(),
              ),
              seed: inkSeed(hitSeed),
              states: states,
              child: const SizedBox.square(dimension: PeelCorner.hit),
            ),
          ),
        ),
      ),
    );
  }
}
