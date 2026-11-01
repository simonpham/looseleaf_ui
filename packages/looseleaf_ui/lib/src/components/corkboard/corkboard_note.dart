import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/corkboard/corkboard.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A note on a [Corkboard]: a 176 px sticky note (any [stock]) in script
/// handwriting, held by a push pin, or by a strip of tape when not
/// [pinned]. Pick it up and drag it, or focus it and use the keyboard.
///
/// [id] names it in the board's layout; [x], [y] and [rotate] place it
/// until the layout says otherwise (with no [rotate] the turn comes from
/// the id, flat at calm density). [bare] drops the sticky note so [child]
/// is the whole note.
///
/// Mirrors `CorkboardNote` in upstream `src/components/ui/corkboard.tsx`.
class CorkboardNote extends StatefulWidget {
  const CorkboardNote({
    super.key,
    required this.id,
    required this.child,
    this.x = Spacing.d16,
    this.y = Spacing.d16,
    this.rotate,
    this.stock = StockName.stickyYellow,
    this.pinned = true,
    this.pinColor,
    this.label,
    this.bare = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// Upstream's `w-44`.
  static const double width = Spacing.d176;

  /// The arrow-key step, and with Shift.
  static const double step = Spacing.d8;
  static const double bigStep = Spacing.d32;

  /// The R-key turn and the furthest turn, in degrees.
  static const double turn = 4;
  static const double maxTurn = 24;

  /// The pin colours picked from the id.
  static const List<PaintKey> pinColors = [
    PaintKey.tomato,
    PaintKey.sky,
    PaintKey.lemon,
    PaintKey.grass,
    PaintKey.grape,
    PaintKey.tangerine,
  ];

  /// Names the note in the board's layout.
  final String id;

  /// What is written on it.
  final Widget child;

  /// The starting left edge on the cork, in pixels.
  final double x;

  /// The starting top edge on the cork, in pixels.
  final double y;

  /// The starting turn in degrees; seeded from [id] when null.
  final double? rotate;

  /// The sticky note's paper.
  final StockName stock;

  /// A push pin on top; tape when false.
  final bool pinned;

  /// The pin's colour; picked from [id] when null.
  final PaintKey? pinColor;

  /// The note's accessible name and the name moves are announced with;
  /// [id] when null.
  final String? label;

  /// No sticky note: [child] is the whole note.
  final bool bare;

  /// Pins the hand of the focus ring.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  /// The seeded turn of note [id], in degrees.
  static double autoTurn(String id) =>
      JsMath.round(((hashSeed(id) % 700) / 100 - 3.5) * 10) / 10;

  /// Where this note sits given the board's [positions].
  NotePosition positionIn(CorkboardValue positions, {required bool calm}) {
    final at = positions[id];
    final auto = switch (calm) {
      true => 0.0,
      false => autoTurn(id),
    };
    return NotePosition(
      x: at?.x ?? x,
      y: at?.y ?? y,
      r: at?.r ?? rotate ?? auto,
      z: at?.z ?? 0,
    );
  }

  @override
  State<CorkboardNote> createState() => _CorkboardNoteState();
}

class _Drag {
  _Drag({
    required this.pointer,
    required this.start,
    required this.origin,
    required this.z,
  }) : at = origin;

  final int pointer;
  final Offset start;
  final Offset origin;
  final int z;
  Offset at;
  bool moved = false;
}

class _MoveIntent extends Intent {
  const _MoveIntent(this.dx, this.dy);

  final double dx;
  final double dy;
}

class _TurnIntent extends Intent {
  const _TurnIntent(this.by);

  final double by;
}

class _FrontIntent extends Intent {
  const _FrontIntent();
}

class _CancelIntent extends Intent {
  const _CancelIntent();
}

const Map<ShortcutActivator, Intent> _shortcuts = {
  SingleActivator(LogicalKeyboardKey.arrowRight): _MoveIntent(
    CorkboardNote.step,
    0,
  ),
  SingleActivator(LogicalKeyboardKey.arrowLeft): _MoveIntent(
    -CorkboardNote.step,
    0,
  ),
  SingleActivator(LogicalKeyboardKey.arrowDown): _MoveIntent(
    0,
    CorkboardNote.step,
  ),
  SingleActivator(LogicalKeyboardKey.arrowUp): _MoveIntent(
    0,
    -CorkboardNote.step,
  ),
  SingleActivator(LogicalKeyboardKey.arrowRight, shift: true): _MoveIntent(
    CorkboardNote.bigStep,
    0,
  ),
  SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true): _MoveIntent(
    -CorkboardNote.bigStep,
    0,
  ),
  SingleActivator(LogicalKeyboardKey.arrowDown, shift: true): _MoveIntent(
    0,
    CorkboardNote.bigStep,
  ),
  SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): _MoveIntent(
    0,
    -CorkboardNote.bigStep,
  ),
  SingleActivator(LogicalKeyboardKey.keyR): _TurnIntent(CorkboardNote.turn),
  SingleActivator(LogicalKeyboardKey.keyR, shift: true): _TurnIntent(
    -CorkboardNote.turn,
  ),
  SingleActivator(LogicalKeyboardKey.enter): _FrontIntent(),
  SingleActivator(LogicalKeyboardKey.space): _FrontIntent(),
  SingleActivator(LogicalKeyboardKey.escape): _CancelIntent(),
};

class _CancelAction extends Action<_CancelIntent> {
  _CancelAction(this.note);

  final _CorkboardNoteState note;

  @override
  bool isEnabled(_CancelIntent intent) => note._drag != null;

  @override
  Object? invoke(_CancelIntent intent) {
    note._cancel();
    return null;
  }
}

class _CorkboardNoteState extends State<CorkboardNote> with InkSeed {
  _Drag? _drag;
  bool _hovered = false;
  bool _focusVisible = false;
  FocusNode? _ownFocus;

  FocusNode get _focus =>
      widget.focusNode ?? (_ownFocus ??= FocusNode(debugLabel: widget.id));

  String get _name => widget.label ?? widget.id;

  late final Map<Type, Action<Intent>> _actions = {
    _MoveIntent: CallbackAction<_MoveIntent>(onInvoke: _move),
    _TurnIntent: CallbackAction<_TurnIntent>(onInvoke: _turn),
    _FrontIntent: CallbackAction<_FrontIntent>(onInvoke: (_) => _front()),
    _CancelIntent: _CancelAction(this),
  };

  @override
  void dispose() {
    _ownFocus?.dispose();
    super.dispose();
  }

  NotePosition _position(CorkboardScope board) => widget.positionIn(
    board.positions,
    calm: LooseleafTheme.of(context).density == LooseleafDensity.calm,
  );

  Size get _max {
    final board = CorkboardScope.of(context);
    final size = context.size ?? Size.zero;
    return Size(
      (board.surface.width - size.width).clamp(0, double.infinity),
      (board.surface.height - size.height).clamp(0, double.infinity),
    );
  }

  Offset _kept(Offset at) {
    final max = _max;
    return Offset(at.dx.clamp(0, max.width), at.dy.clamp(0, max.height));
  }

  Object? _move(_MoveIntent intent) {
    final board = CorkboardScope.of(context);
    if (board.disabled) return null;
    final pos = _position(board);
    final next = _kept(
      Offset((pos.x ?? 0) + intent.dx, (pos.y ?? 0) + intent.dy),
    );
    board.update(
      widget.id,
      NotePosition(x: next.dx, y: next.dy),
      '$_name at ${_num(next.dx)}, ${_num(next.dy)}.',
    );
    return null;
  }

  Object? _turn(_TurnIntent intent) {
    final board = CorkboardScope.of(context);
    if (board.disabled) return null;
    final turned = ((_position(board).r ?? 0) + intent.by).clamp(
      -CorkboardNote.maxTurn,
      CorkboardNote.maxTurn,
    );
    board.update(
      widget.id,
      NotePosition(r: turned),
      '$_name turned to ${_num(turned)} degrees.',
    );
    return null;
  }

  void _front() {
    final board = CorkboardScope.of(context);
    if (board.disabled) return;
    board.update(
      widget.id,
      NotePosition(z: board.topZ + 1),
      '$_name brought to the front.',
    );
  }

  void _cancel() {
    if (_drag == null) return;
    setState(() => _drag = null);
    CorkboardScope.of(context).lift(null);
  }

  static String _num(double v) => JsMath.numberToString(v);

  void _down(PointerDownEvent event) {
    final board = CorkboardScope.of(context);
    if (board.disabled) return;
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    final pos = _position(board);
    setState(
      () => _drag = _Drag(
        pointer: event.pointer,
        start: event.position,
        origin: _kept(Offset(pos.x ?? 0, pos.y ?? 0)),
        z: board.topZ + 1,
      ),
    );
    board.lift(widget.id);
    _focus.requestFocus();
  }

  void _moved(PointerMoveEvent event) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    final delta = event.position - drag.start;
    if (!drag.moved && delta.distance < 3) return;
    drag.moved = true;
    setState(() => drag.at = _kept(drag.origin + delta));
  }

  void _up(PointerEvent event, {required bool cancel}) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    final board = CorkboardScope.of(context);
    setState(() => _drag = null);
    board.lift(null);
    if (cancel || !drag.moved) return;
    final x = JsMath.round(drag.at.dx), y = JsMath.round(drag.at.dy);
    board.update(
      widget.id,
      NotePosition(x: x, y: y, z: drag.z),
      '$_name moved to ${_num(x)}, ${_num(y)}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final board = CorkboardScope.of(context);
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    final pos = _position(board);
    final drag = _drag;
    final dragging = drag != null && drag.moved;
    final enabled = !board.disabled;
    final scale = switch ((dragging, _hovered && enabled)) {
      (true, _) => 1.05,
      (false, true) => 1.015,
      (false, false) => 1.0,
    };
    final duration = InkMotion.of(context, InkMotion.hover);
    final sheet = switch (widget.bare) {
      true => widget.child,
      false => SizedBox(
        width: CorkboardNote.width,
        child: Paper(
          stock: widget.stock,
          edge: const EdgeSpec.all(EdgeKind.cut),
          tilt: false,
          tape: switch (widget.pinned) {
            true => null,
            false => PaperTape.top,
          },
          shadow: switch (dragging) {
            true => PaperShadow.lift,
            false => PaperShadow.stock,
          },
          seed: '${widget.id}|sheet',
          padding: const EdgeInsets.fromLTRB(
            Spacing.d14,
            Spacing.d24,
            Spacing.d14,
            Spacing.d16,
          ),
          child: DefaultTextStyle.merge(
            style: theme.typography.face(
              KevinSansFace.script,
              cssSize: 20,
              cssLineHeight: 1.25,
              color: theme.colors.ink,
            ),
            child: widget.child,
          ),
        ),
      ),
    };
    final note = Stack(
      clipBehavior: Clip.none,
      children: [
        InkSurface(
          source: RecipeInkSource(
            corkNoteRecipe,
            const NoParams(),
            json: const NoParams().toJson(),
          ),
          seed: inkSeed(widget.seed),
          states: {
            ...widget.forcedStates,
            if (_focusVisible && enabled) InkState.focused,
          },
          child: sheet,
        ),
        if (widget.pinned && !calm)
          Positioned(
            top: -Spacing.d10,
            left: 0,
            right: 0,
            child: Center(
              child: CorkboardPin(
                color:
                    widget.pinColor ??
                    CorkboardNote.pinColors[hashSeed(widget.id) %
                        CorkboardNote.pinColors.length],
                lifted: dragging,
                seed: '${widget.id}|pin',
              ),
            ),
          ),
      ],
    );
    final offset = switch (drag) {
      final held? => held.at - held.origin,
      null => Offset.zero,
    };
    return Semantics(
      container: true,
      label: _name,
      hint: Corkboard.help,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: _focus,
        autofocus: widget.autofocus,
        shortcuts: _shortcuts,
        actions: _actions,
        onShowFocusHighlight: (visible) =>
            setState(() => _focusVisible = visible),
        onShowHoverHighlight: (hovered) => setState(() => _hovered = hovered),
        mouseCursor: switch ((enabled, dragging)) {
          (false, _) => SystemMouseCursors.basic,
          (true, true) => SystemMouseCursors.grabbing,
          (true, false) => SystemMouseCursors.grab,
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _down,
          onPointerMove: _moved,
          onPointerUp: (event) => _up(event, cancel: false),
          onPointerCancel: (event) => _up(event, cancel: true),
          child: Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: (pos.r ?? 0) * math.pi / 180,
              child: AnimatedScale(
                scale: scale,
                duration: duration,
                curve: InkMotion.settle,
                child: note,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
