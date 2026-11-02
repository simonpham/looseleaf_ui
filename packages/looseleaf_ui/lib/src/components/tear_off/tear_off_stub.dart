import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/tear_off/tear_off_pose.dart';
import 'package:looseleaf_ui/src/components/tear_off/tear_off_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The part of a [TearOff] that comes off: a flat sheet perforated toward
/// the body, with the scissors already on the dotted line and a pencil
/// arrow showing which way to pull.
///
/// It is a button named by its text (or [label]): a tap, Enter or Space
/// tears it; a pull follows the pointer, tears at half way and springs
/// back short of it. Torn, it swings off, fades and leaves the tab order.
///
/// Mirrors `TearOffStub` in upstream `src/components/ui/tear-off.tsx`.
class TearOffStub extends StatefulWidget {
  const TearOffStub({
    super.key,
    required this.children,
    this.stock = StockName.indexCard,
    this.label,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(Spacing.d16),
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.spacing = Spacing.d4,
    this.seed,
    this.focusNode,
    this.forcedStates = const {},
  });

  /// The help a screen reader reads with the stub.
  static const String help =
      'Press Enter or Space to tear it off along the dotted line, or pull it '
      'away with a pointer.';

  /// How far a press must move to count as a pull.
  static const double dragSlop = 4;

  /// The shortest distance a full pull takes.
  static const double minPull = 56;

  /// `--ll-dur-drop`.
  static const Duration drop = Duration(milliseconds: 340);

  /// `h-7 w-9`: the hint arrow's box.
  static const Size hintSize = Size(36, 28);

  /// The lines on the stub, centred.
  final List<Widget> children;

  final StockName stock;

  /// The button's name; its text when null.
  final String? label;

  /// A fixed width, padding included (upstream `w-32`).
  final double? width;

  /// A fixed height, padding included.
  final double? height;

  /// `p-4`.
  final EdgeInsetsGeometry padding;

  /// Where the lines sit along the stub (`justify-center`): start, end
  /// or centred.
  final MainAxisAlignment mainAxisAlignment;

  /// The gap between lines (`gap-1`).
  final double spacing;

  /// Pins the sheet, the seam and the hint.
  final String? seed;

  final FocusNode? focusNode;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<TearOffStub> createState() => _TearOffStubState();
}

class _TearOffStubState extends State<TearOffStub>
    with TickerProviderStateMixin, InkSeed {
  late final AnimationController _settle;
  late final AnimationController _drop;
  TearOffPose _from = TearOffPose.rest;
  TearOffPose _to = TearOffPose.rest;
  ({int pointer, Offset start, double size, double progress, bool moved})?
  _drag;
  bool _pulled = false;
  bool? _wasTorn;
  bool _wasRestored = false;

  TearOffPose get _pose => TearOffPose.lerp(
    _from,
    _to,
    InkMotion.settle.transform(_settle.value),
  );

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(vsync: this, value: 1);
    _drop = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = TearOffScope.of(context);
    if (_wasTorn == null) {
      _wasTorn = scope.torn;
      _to = _target(scope);
      _from = _to;
    }
    if (scope.torn != _wasTorn) {
      _wasTorn = scope.torn;
      _moveTo(_target(scope));
    }
    if (scope.restored && !_wasRestored) {
      _drop.duration = InkMotion.of(context, TearOffStub.drop);
      _drop.forward(from: 0);
    }
    _wasRestored = scope.restored;
  }

  TearOffPose _target(TearOffScope scope) => switch (scope.torn) {
    true => TearOffPose.torn(
      orientation: scope.orientation,
      direction: Directionality.of(context),
    ),
    false => TearOffPose.rest,
  };

  void _moveTo(TearOffPose target) {
    _from = _pose;
    _to = target;
    final duration = InkMotion.of(context, TearOffStub.drop);
    _settle.duration = duration;
    _settle.forward(from: 0);
  }

  @override
  void dispose() {
    _settle.dispose();
    _drop.dispose();
    super.dispose();
  }

  void _down(PointerDownEvent event) {
    final scope = TearOffScope.of(context);
    if (scope.disabled || scope.torn || event.buttons != kPrimaryButton) {
      return;
    }
    final box = context.findRenderObject();
    final extent = switch ((box, scope.orientation)) {
      (final RenderBox b, Axis.vertical) when b.hasSize => b.size.height,
      (final RenderBox b, Axis.horizontal) when b.hasSize => b.size.width,
      _ => 100.0,
    };
    _pulled = false;
    _drag = (
      pointer: event.pointer,
      start: event.position,
      size: extent,
      progress: 0,
      moved: false,
    );
  }

  void _move(PointerMoveEvent event) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    final scope = TearOffScope.of(context);
    final direction = Directionality.of(context);
    final delta = event.position - drag.start;
    final along = switch ((scope.orientation, direction)) {
      (Axis.vertical, _) => delta.dy,
      (Axis.horizontal, TextDirection.rtl) => -delta.dx,
      (Axis.horizontal, TextDirection.ltr) => delta.dx,
    };
    final moved = drag.moved || along.abs() > TearOffStub.dragSlop;
    final reach = switch (drag.size * 0.7 > TearOffStub.minPull) {
      true => drag.size * 0.7,
      false => TearOffStub.minPull,
    };
    final progress = (along / reach).clamp(0.0, 1.0);
    _drag = (
      pointer: drag.pointer,
      start: drag.start,
      size: drag.size,
      progress: progress,
      moved: moved,
    );
    _settle.stop();
    setState(() {
      _from = TearOffPose.pulled(
        progress,
        orientation: scope.orientation,
        direction: direction,
      );
      _to = _from;
    });
    if (progress >= 1) _release(tear: true);
  }

  void _release({required bool tear}) {
    _drag = null;
    _pulled = true;
    if (tear) {
      TearOffScope.of(context).tear();
      return;
    }
    _moveTo(TearOffPose.rest);
  }

  void _up(PointerUpEvent event) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    if (!drag.moved) {
      _drag = null;
      return;
    }
    _release(tear: drag.progress >= 0.5);
  }

  void _cancel(PointerCancelEvent event) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    _release(tear: false);
  }

  void _activate() {
    if (_pulled) {
      _pulled = false;
      return;
    }
    TearOffScope.of(context).tear();
  }

  @override
  Widget build(BuildContext context) {
    final scope = TearOffScope.of(context);
    if (scope.gone) return const SizedBox.shrink();
    final direction = Directionality.of(context);
    final seed = inkSeed(widget.seed);
    final interactive = !scope.disabled && !scope.torn;
    return ExcludeSemantics(
      excluding: scope.torn,
      child: Semantics(
        container: true,
        button: true,
        enabled: !scope.disabled,
        label: widget.label,
        hint: TearOffStub.help,
        child: Listener(
          onPointerDown: _down,
          onPointerMove: _move,
          onPointerUp: _up,
          onPointerCancel: _cancel,
          child: InkInteraction(
            enabled: interactive,
            onActivate: _activate,
            states: widget.forcedStates,
            focusNode: widget.focusNode,
            mouseCursor: switch (_drag) {
              null => SystemMouseCursors.grab,
              _ => SystemMouseCursors.grabbing,
            },
            disabledMouseCursor: MouseCursor.defer,
            builder: (context, states) => AnimatedBuilder(
              animation: Listenable.merge([_settle, _drop]),
              builder: (context, child) =>
                  _posed(scope, direction, child ?? const SizedBox.shrink()),
              child: _stub(context, scope, direction, seed, states),
            ),
          ),
        ),
      ),
    );
  }

  Widget _posed(TearOffScope scope, TextDirection direction, Widget child) {
    final pose = _pose;
    final origin = switch ((scope.orientation, direction)) {
      (Axis.vertical, _) => Alignment.topLeft,
      (Axis.horizontal, TextDirection.rtl) => Alignment.bottomRight,
      (Axis.horizontal, TextDirection.ltr) => Alignment.bottomLeft,
    };
    Widget posed = Opacity(
      opacity: pose.opacity,
      child: Transform.translate(
        offset: Offset(pose.dx, pose.dy),
        child: Transform.rotate(
          angle: pose.turn,
          alignment: origin,
          child: child,
        ),
      ),
    );
    if (_drop.isAnimating) posed = _dropped(posed);
    return IgnorePointer(ignoring: scope.torn, child: posed);
  }

  Widget _dropped(Widget child) {
    final t = InkMotion.settle.transform(_drop.value);
    final (dy, degrees, scale) = switch (t) {
      < 0.62 => (
        -26 + 28 * t / 0.62,
        -2.4 + 2.75 * t / 0.62,
        1.05 - 0.055 * t / 0.62,
      ),
      < 0.82 => (
        2 - 3 * (t - 0.62) / 0.2,
        0.35 - 0.45 * (t - 0.62) / 0.2,
        0.995 + 0.005 * (t - 0.62) / 0.2,
      ),
      _ => (-1 + (t - 0.82) / 0.18, -0.1 + 0.1 * (t - 0.82) / 0.18, 1.0),
    };
    final opacity = switch (t < 0.62) {
      true => (t / 0.62).clamp(0.0, 1.0),
      false => 1.0,
    };
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Transform.rotate(
          angle: degrees * 3.141592653589793 / 180,
          child: Transform.scale(scale: scale, child: child),
        ),
      ),
    );
  }

  Widget _stub(
    BuildContext context,
    TearOffScope scope,
    TextDirection direction,
    String seed,
    Set<InkState> states,
  ) {
    final vertical = scope.orientation == Axis.vertical;
    final rtl = direction == TextDirection.rtl;
    final side = scope.sides(direction).stub;
    final seam = TearSeamParams(
      scissors: true,
      inset: switch (rtl) {
        true => -5,
        false => 5,
      },
    );
    final hint = TearHintParams(
      toward: switch ((vertical, rtl)) {
        (true, _) => TearToward.down,
        (false, true) => TearToward.left,
        (false, false) => TearToward.right,
      },
    );
    final sheet = Paper(
      stock: widget.stock,
      edge: scope.edge(side),
      tilt: false,
      padding: widget.padding,
      seed: seed,
      child: Align(
        alignment: switch (widget.mainAxisAlignment) {
          MainAxisAlignment.start => Alignment.topCenter,
          MainAxisAlignment.end => Alignment.bottomCenter,
          _ => Alignment.center,
        },
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: widget.spacing,
            children: [
              for (final line in widget.children)
                DefaultTextStyle.merge(
                  textAlign: TextAlign.center,
                  child: line,
                ),
            ],
          ),
        ),
      ),
    );
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          InkSurface(
            source: RecipeInkSource(
              tearStubRecipe,
              const NoParams(),
              json: const NoParams().toJson(),
            ),
            seed: seed,
            states: states,
            child: sheet,
          ),
          switch (vertical) {
            true => Positioned(
              left: Spacing.d12,
              right: Spacing.d12,
              top: -Spacing.d8,
              height: Spacing.d16,
              child: _art(tearSeamRecipe, seam, seam.toJson(), '$seed|seam'),
            ),
            false => PositionedDirectional(
              top: Spacing.d12,
              bottom: Spacing.d12,
              start: -Spacing.d8,
              width: Spacing.d16,
              child: _art(tearSeamRecipe, seam, seam.toJson(), '$seed|seam'),
            ),
          },
          switch (vertical) {
            true => Positioned(
              bottom: Spacing.d4,
              left: 0,
              right: 0,
              child: Center(child: _hint(hint, '$seed|hint')),
            ),
            false => PositionedDirectional(
              bottom: Spacing.d4,
              end: Spacing.d4,
              child: _hint(hint, '$seed|hint'),
            ),
          },
        ],
      ),
    );
  }

  Widget _hint(TearHintParams params, String seed) => SizedBox.fromSize(
    size: TearOffStub.hintSize,
    child: _art(tearHintRecipe, params, params.toJson(), seed),
  );

  Widget _art<P>(
    Recipe<P> recipe,
    P params,
    Map<String, Object?> json,
    String seed,
  ) => IgnorePointer(
    child: ExcludeSemantics(
      child: InkSurface(
        source: RecipeInkSource(recipe, params, json: json),
        seed: seed,
        still: true,
        child: const SizedBox.expand(),
      ),
    ),
  );
}
