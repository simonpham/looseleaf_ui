import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sticker/sticker.dart';
import 'package:looseleaf_ui/src/components/sticker_board/sticker_board.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

enum _Mode { move, rotate, scale }

class _Drag {
  _Drag({
    required this.pointer,
    required this.mode,
    required this.start,
    required this.center,
    required this.item,
  }) : a0 = math.atan2(start.dy - center.dy, start.dx - center.dx),
       d0 = math.max(4, (start - center).distance),
       live = item;

  final int pointer;
  final _Mode mode;
  final Offset start;
  final Offset center;
  final StickerBoardItem item;
  final double a0;
  final double d0;
  StickerBoardItem live;
  bool moved = false;
}

/// One sticker placed on a [StickerBoardCanvas], centred on its item's
/// position, turned and scaled: the sticker art with its frame (a hover
/// outline, a focus ring, and when selected a blue dashed frame with a
/// rotate ring above and a scale square at the lower right corner).
///
/// Built by the canvas for each item; it handles the drags and the keys
/// (see [StickerBoard]).
///
/// Mirrors `BoardItem` in upstream `src/components/ui/sticker-board.tsx`.
class StickerBoardSticker extends StatefulWidget {
  const StickerBoardSticker({super.key, required this.item});

  /// The sticker.
  final StickerBoardItem item;

  /// Room around the sticker for its handles.
  static const double reach = Spacing.d56;

  /// How far the selection frame sits outside the sticker.
  static const double out = 5;

  @override
  State<StickerBoardSticker> createState() => _StickerBoardStickerState();
}

class _StickerBoardStickerState extends State<StickerBoardSticker> {
  final FocusNode _focus = FocusNode();
  _Drag? _drag;
  bool _hovered = false;
  bool _focusVisible = false;

  late final Map<Type, Action<Intent>> _actions = {
    StickerMoveIntent: CallbackAction<StickerMoveIntent>(onInvoke: _move),
    StickerTurnIntent: CallbackAction<StickerTurnIntent>(
      onInvoke: (intent) =>
          _edit((board, id) => board.turn(id, intent.degrees)),
    ),
    StickerResizeIntent: CallbackAction<StickerResizeIntent>(
      onInvoke: (intent) =>
          _edit((board, id) => board.resize(id, intent.factor)),
    ),
    StickerResetIntent: CallbackAction<StickerResetIntent>(
      onInvoke: (_) => _edit(
        (board, id) => board.patch(
          id,
          (s) => s.copyWith(rot: 0, scale: 1),
          '${board.nameOf(id)} set upright at full size.',
        ),
      ),
    ),
    StickerReorderIntent: CallbackAction<StickerReorderIntent>(
      onInvoke: (intent) => _edit((board, id) => board.reorder(id, intent.how)),
    ),
    StickerDeleteIntent: CallbackAction<StickerDeleteIntent>(
      onInvoke: (_) => _edit((board, id) {
        board.remove(id);
        board.surfaceFocus.requestFocus();
      }),
    ),
    StickerDuplicateIntent: CallbackAction<StickerDuplicateIntent>(
      onInvoke: (_) => _edit((board, id) => board.duplicate(id)),
    ),
    StickerReleaseIntent: CallbackAction<StickerReleaseIntent>(
      onInvoke: (_) => _release(),
    ),
  };

  StickerBoardScope get _scope => StickerBoardScope.of(context);

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Object? _edit(void Function(StickerBoardState board, String id) edit) {
    final scope = _scope;
    if (!scope.editable) return null;
    edit(scope.board, widget.item.id);
    return null;
  }

  StickerBoardItem get _current {
    for (final s in _scope.board.items) {
      if (s.id == widget.item.id) return s;
    }
    return widget.item;
  }

  Size get _art {
    final face = _face;
    if (face == null) return Size.zero;
    return Size(face.box.w, face.box.h);
  }

  StickerFace? get _face => _faceArt(_scope.board.widget.size).face;

  StickerFaceArt _faceArt(double size) => StickerFaceArt(
    name: widget.item.name,
    size: size,
    seed: widget.item.id,
    idPrefix: 'll-sb${widget.item.id}'.replaceAll(RegExp('[^a-zA-Z0-9-]'), ''),
  );

  Object? _move(StickerMoveIntent intent) {
    final scope = _scope;
    if (!scope.editable) return null;
    final board = scope.board;
    final cur = _current;
    final at = StickerBoardOps.keepIn(
      cur.x + intent.dx,
      cur.y + intent.dy,
      art: _art,
      rot: cur.rot,
      scale: cur.scale,
      canvas: board.canvasSize,
      mode: board.widget.bounds,
    );
    board.patch(
      cur.id,
      (s) => s.copyWith(x: at.dx, y: at.dy),
      '${board.nameOf(cur.id)} at ${JsMath.numberToString(at.dx)}, '
      '${JsMath.numberToString(at.dy)}.',
    );
    return null;
  }

  void _release() {
    final scope = _scope;
    if (!scope.editable) return;
    if (_drag != null) {
      setState(() => _drag = null);
      scope.board.lift(null);
      return;
    }
    scope.board.select(null);
    _focus.unfocus();
  }

  void _start(PointerDownEvent event, _Mode mode) {
    final scope = _scope;
    if (!scope.editable) return;
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    scope.board.select(widget.item.id);
    final box = _bodyKey.currentContext?.findRenderObject();
    if (box is! RenderBox) return;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    setState(
      () => _drag = _Drag(
        pointer: event.pointer,
        mode: mode,
        start: event.position,
        center: center,
        item: _current,
      ),
    );
    scope.board.lift(widget.item.id);
    _focus.requestFocus();
  }

  void _moved(PointerMoveEvent event) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    final delta = event.position - drag.start;
    if (!drag.moved && delta.distance < 3) return;
    drag.moved = true;
    final board = _scope.board;
    final from = drag.item;
    final next = switch (drag.mode) {
      _Mode.move => () {
        final at = StickerBoardOps.keepIn(
          from.x + delta.dx,
          from.y + delta.dy,
          art: _art,
          rot: drag.live.rot,
          scale: drag.live.scale,
          canvas: board.canvasSize,
          mode: board.widget.bounds,
        );
        return drag.live.copyWith(x: at.dx, y: at.dy);
      }(),
      _Mode.rotate => () {
        final p = event.position - drag.center;
        var rot = from.rot + (math.atan2(p.dy, p.dx) - drag.a0) * 180 / math.pi;
        if (HardwareKeyboard.instance.isShiftPressed) {
          rot = JsMath.round(rot / StickerBoard.bigTurn) * StickerBoard.bigTurn;
        }
        return drag.live.copyWith(rot: StickerBoardOps.turnTo(rot));
      }(),
      _Mode.scale => drag.live.copyWith(
        scale: StickerBoardOps.round2(
          from.scale * ((event.position - drag.center).distance / drag.d0),
        ).clamp(board.widget.minScale, board.widget.maxScale),
      ),
    };
    setState(() => drag.live = next);
  }

  void _up(PointerEvent event, {required bool cancel}) {
    final drag = _drag;
    if (drag == null || drag.pointer != event.pointer) return;
    final board = _scope.board;
    setState(() => _drag = null);
    board.lift(null);
    if (cancel || !drag.moved) return;
    final live = drag.live;
    final name = board.nameOf(live.id);
    switch (drag.mode) {
      case _Mode.move:
        final x = JsMath.round(live.x), y = JsMath.round(live.y);
        board.patch(
          live.id,
          (s) => s.copyWith(x: x, y: y),
          '$name moved to ${JsMath.numberToString(x)}, '
          '${JsMath.numberToString(y)}.',
        );
      case _Mode.rotate:
        board.patch(
          live.id,
          (s) => s.copyWith(rot: live.rot),
          '$name turned to ${JsMath.numberToString(live.rot)} degrees.',
        );
      case _Mode.scale:
        board.patch(
          live.id,
          (s) => s.copyWith(scale: live.scale),
          '$name at ${JsMath.round(live.scale * 100).toInt()} percent.',
        );
    }
  }

  final GlobalKey _bodyKey = GlobalKey();

  Widget _listen(Widget child, _Mode mode) => Listener(
    behavior: HitTestBehavior.opaque,
    onPointerDown: (event) => _start(event, mode),
    onPointerMove: _moved,
    onPointerUp: (event) => _up(event, cancel: false),
    onPointerCancel: (event) => _up(event, cancel: true),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final scope = _scope;
    final board = scope.board;
    final art = _faceArt(board.widget.size);
    final face = art.face;
    if (face == null) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    final item = _drag?.live ?? widget.item;
    final dragging = _drag?.moved ?? false;
    final selected = scope.selectedId == item.id;
    final editable = scope.editable;
    final s = item.scale;
    final w = face.box.w * s, h = face.box.h * s;
    const reach = StickerBoardSticker.reach;
    const out = StickerBoardSticker.out;
    const hit = StickerHandle.hit;
    final calm = theme.density == LooseleafDensity.calm;
    final scale = switch ((dragging, _hovered && editable && !calm)) {
      (true, _) => 1.06,
      (false, true) => 1.03,
      (false, false) => 1.0,
    };
    final params = ItemFrameParams(selected: selected, handles: editable);
    final body = AnimatedScale(
      scale: scale,
      duration: InkMotion.of(context, InkMotion.hover),
      curve: InkMotion.settle,
      child: InkSurface(
        source: RecipeInkSource(
          stickerBoardItemRecipe,
          params,
          json: params.toJson(),
        ),
        seed: item.id,
        states: {
          if (_hovered && editable) InkState.hovered,
          if (_focusVisible && editable) InkState.focused,
        },
        child: SizedBox(
          key: _bodyKey,
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -face.box.x * s,
                top: -face.box.y * s,
                child: Transform.scale(
                  scale: s,
                  alignment: Alignment.topLeft,
                  child: art,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final cursor = switch ((editable, dragging)) {
      (false, _) => MouseCursor.defer,
      (true, true) => SystemMouseCursors.grabbing,
      (true, false) => SystemMouseCursors.grab,
    };
    return Positioned(
      left: item.x - w / 2 - reach,
      top: item.y - h / 2 - reach,
      width: w + 2 * reach,
      height: h + 2 * reach,
      child: Transform.rotate(
        angle: item.rot * math.pi / 180,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: reach,
              top: reach,
              width: w,
              height: h,
              child: Semantics(
                container: true,
                label: stickerLabel(item.name),
                hint: switch (editable) {
                  true => StickerBoard.help,
                  false => null,
                },
                selected: selected,
                child: FocusableActionDetector(
                  enabled: editable,
                  focusNode: _focus,
                  shortcuts: stickerBoardShortcuts,
                  actions: _actions,
                  mouseCursor: cursor,
                  onFocusChange: (focused) {
                    if (focused && editable && !selected) {
                      board.select(item.id);
                    }
                  },
                  onShowFocusHighlight: (visible) =>
                      setState(() => _focusVisible = visible),
                  onShowHoverHighlight: (hovered) =>
                      setState(() => _hovered = hovered),
                  child: _listen(body, _Mode.move),
                ),
              ),
            ),
            if (selected && editable) ...[
              Positioned(
                left: reach + w / 2 - hit / 2,
                top: reach - (out + StickerHandle.rotateUp) - hit / 2,
                width: hit,
                height: hit,
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: _listen(const SizedBox.expand(), _Mode.rotate),
                ),
              ),
              Positioned(
                left:
                    reach +
                    w +
                    out +
                    StickerHandle.scaleOut -
                    StickerHandle.scaleSize / 2 -
                    hit / 2,
                top:
                    reach +
                    h +
                    out +
                    StickerHandle.scaleOut -
                    StickerHandle.scaleSize / 2 -
                    hit / 2,
                width: hit,
                height: hit,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  child: _listen(const SizedBox.expand(), _Mode.scale),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
