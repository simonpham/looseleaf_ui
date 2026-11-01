import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sticker/sticker.dart';
import 'package:looseleaf_ui/src/components/sticker_sheet/sticker_sheet.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One sticker on a [StickerSheet], in a cell of its size + 22 px: the
/// sticker in its kiss-cut line. Hover or focus curls a corner up; a tap,
/// Enter or Space peels it off (and sticks it back when the sheet is
/// restorable); a mouse can pull it off by dragging it 18 px away.
///
/// [id] tells two of the same sticker apart (the [name] when null);
/// [label] names it (from the name when null); [size] overrides the
/// sheet's. An unknown [name] shows nothing.
///
/// Mirrors `StickerSheetItem` in upstream
/// `src/components/ui/sticker-sheet.tsx`.
class StickerSheetItem extends StatefulWidget {
  const StickerSheetItem({
    super.key,
    required this.name,
    this.id,
    this.label,
    this.size,
    this.focusNode,
    this.forcedStates = const {},
  });

  /// The sticker's name in the catalog.
  final String name;

  /// Tells two of the same sticker apart; [name] when null.
  final String? id;

  /// The sticker's name for people; from [name] when null.
  final String? label;

  /// The sticker's size in pixels; the sheet's when null.
  final double? size;

  final FocusNode? focusNode;

  /// States shown whatever the input (`hovered` curls the corner,
  /// `focused` rings the cell), for goldens.
  final Set<InkState> forcedStates;

  /// How far a pull starts, and how far it must go to peel.
  static const double dragAt = Spacing.d6;
  static const double dragOff = Spacing.d18;

  @override
  State<StickerSheetItem> createState() => _StickerSheetItemState();
}

class _Pull {
  _Pull(this.pointer, this.start);

  final int pointer;
  final Offset start;
  bool started = false;
}

class _StickerSheetItemState extends State<StickerSheetItem> {
  bool _warm = false;
  bool _hovered = false;
  bool _focusVisible = false;
  bool _dropped = false;
  bool _suppress = false;
  _Pull? _pull;
  Offset _carry = Offset.zero;

  String get _id => widget.id ?? widget.name;

  String get _label => widget.label ?? stickerLabel(widget.name);

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
  };

  StickerSheetPeel _item({required bool dragged, Offset? position}) =>
      StickerSheetPeel(
        id: _id,
        name: widget.name,
        label: _label,
        dragged: dragged,
        position: position,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final peeled = StickerSheetScope.of(context).peeled.contains(_id);
    if (peeled) return;
    _dropped = false;
    _carry = Offset.zero;
  }

  void _activate() {
    final sheet = StickerSheetScope.of(context);
    final peeled = sheet.peeled.contains(_id);
    if (sheet.disabled || (peeled && !sheet.restorable)) return;
    if (peeled) {
      sheet.stick(_item(dragged: false));
      return;
    }
    sheet.peel(_item(dragged: false));
  }

  void _onTap() {
    if (_suppress) {
      _suppress = false;
      return;
    }
    _activate();
  }

  void _down(PointerDownEvent event) {
    _warmUp();
    _suppress = false;
    final sheet = StickerSheetScope.of(context);
    if (sheet.disabled || sheet.peeled.contains(_id)) return;
    if (event.kind == PointerDeviceKind.touch) return;
    if (event.buttons != kPrimaryMouseButton) return;
    _pull = _Pull(event.pointer, event.position);
  }

  void _moved(PointerMoveEvent event) {
    final pull = _pull;
    if (pull == null || pull.pointer != event.pointer) return;
    final delta = event.position - pull.start;
    if (!pull.started && delta.distance < StickerSheetItem.dragAt) return;
    pull.started = true;
    setState(() => _carry = delta);
  }

  void _up(PointerEvent event, {required bool cancel}) {
    final pull = _pull;
    if (pull == null || pull.pointer != event.pointer) return;
    _pull = null;
    if (!pull.started) return;
    _suppress = !cancel;
    final far =
        (event.position - pull.start).distance >= StickerSheetItem.dragOff;
    if (cancel || !far) {
      setState(() => _carry = Offset.zero);
      return;
    }
    setState(() => _dropped = true);
    StickerSheetScope.of(
      context,
    ).peel(_item(dragged: true, position: event.position));
  }

  void _warmUp() {
    if (_warm) return;
    setState(() => _warm = true);
  }

  @override
  Widget build(BuildContext context) {
    final sheet = StickerSheetScope.of(context);
    final px = widget.size ?? sheet.size;
    final prefix = 'll-ss$_id'.replaceAll(RegExp('[^a-zA-Z0-9-]'), '');
    final art = StickerFaceArt(
      name: widget.name,
      size: px,
      seed: _id,
      idPrefix: prefix,
    );
    final face = art.face;
    if (face == null) return const SizedBox.shrink();
    final cell = StickerSheet.cellOf(px);
    final at = Offset(
      cell / 2 - (face.box.x + face.box.w / 2),
      cell / 2 - (face.box.y + face.box.h / 2),
    );
    final peeled = sheet.peeled.contains(_id);
    final spent = peeled && !sheet.restorable;
    final enabled = !sheet.disabled;
    final dragging = _pull?.started ?? false;
    final hovered =
        (_hovered && enabled) || widget.forcedStates.contains(InkState.hovered);
    final focused =
        (_focusVisible && enabled) ||
        widget.forcedStates.contains(InkState.focused);
    final curled = hovered || focused || dragging || peeled;
    final warm = _warm || curled;
    final fade = InkMotion.of(context, InkMotion.fade);
    final hover = InkMotion.of(context, InkMotion.hover);
    final flight = switch ((peeled, _dropped)) {
      (true, false) =>
        Matrix4.identity()
          ..translateByDouble(Spacing.d16, -Spacing.d24, 0, 1)
          ..rotateZ(-12 * math.pi / 180)
          ..scaleByDouble(1.1, 1.1, 1, 1),
      _ => Matrix4.identity(),
    };
    final held = switch ((dragging, hovered)) {
      (true, _) =>
        Matrix4.identity()
          ..translateByDouble(_carry.dx, _carry.dy, 0, 1)
          ..rotateZ((_carry.dx * 0.06).clamp(-14, 14) * math.pi / 180)
          ..scaleByDouble(1.1, 1.1, 1, 1),
      (false, true) =>
        Matrix4.identity()
          ..rotateZ(-2 * math.pi / 180)
          ..scaleByDouble(1.04, 1.04, 1, 1),
      (false, false) =>
        Matrix4.identity()..translateByDouble(_carry.dx, _carry.dy, 0, 1),
    };
    final faces = Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedOpacity(
          opacity: switch (curled) {
            true => 0,
            false => 1,
          },
          duration: fade,
          child: art,
        ),
        if (warm)
          AnimatedOpacity(
            opacity: switch (curled) {
              true => 1,
              false => 0,
            },
            duration: fade,
            child: StickerFaceArt(
              name: widget.name,
              size: px,
              seed: _id,
              peel: true,
              idPrefix: '${prefix}p',
            ),
          ),
      ],
    );
    final flying = AnimatedOpacity(
      opacity: switch (peeled) {
        true => 0,
        false => 1,
      },
      duration: switch (_dropped) {
        true => fade,
        false => InkMotion.of(context, InkMotion.sheet),
      },
      child: AnimatedContainer(
        transform: flight,
        transformAlignment: Alignment.center,
        duration: switch (_dropped) {
          true => fade,
          false => InkMotion.of(context, InkMotion.sheet),
        },
        curve: InkMotion.settle,
        child: AnimatedContainer(
          transform: held,
          transformAlignment: Alignment.center,
          duration: switch (dragging) {
            true => Duration.zero,
            false => hover,
          },
          curve: InkMotion.settle,
          child: faces,
        ),
      ),
    );
    return SizedBox.square(
      dimension: cell,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: at.dx,
            top: at.dy,
            child: StickerFaceArt(
              name: widget.name,
              size: px,
              seed: _id,
              idPrefix: prefix,
              kiss: true,
            ),
          ),
          Positioned.fill(child: _button(peeled, spent, enabled, focused)),
          Positioned(
            left: at.dx,
            top: at.dy,
            width: face.w,
            height: face.h,
            child: IgnorePointer(child: flying),
          ),
        ],
      ),
    );
  }

  Widget _button(bool peeled, bool spent, bool enabled, bool focused) {
    final label = switch ((peeled, spent)) {
      (false, _) => 'Peel $_label sticker',
      (true, false) => 'Put $_label sticker back',
      (true, true) => '$_label sticker, peeled',
    };
    return Semantics(
      container: true,
      button: true,
      enabled: enabled && !spent,
      label: label,
      onTap: switch (enabled) {
        true => _activate,
        false => null,
      },
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        actions: _actions,
        onShowFocusHighlight: (visible) {
          setState(() => _focusVisible = visible);
          if (visible) _warmUp();
        },
        onShowHoverHighlight: (hovered) {
          setState(() => _hovered = hovered);
          if (hovered) _warmUp();
        },
        mouseCursor: switch (enabled && !spent) {
          true => SystemMouseCursors.grab,
          false => SystemMouseCursors.basic,
        },
        child: Listener(
          onPointerDown: _down,
          onPointerMove: _moved,
          onPointerUp: (event) => _up(event, cancel: false),
          onPointerCancel: (event) => _up(event, cancel: true),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: switch (enabled) {
              true => _onTap,
              false => null,
            },
            child: InkSurface(
              source: RecipeInkSource(
                stickerSlotRecipe,
                const NoParams(),
                json: const NoParams().toJson(),
              ),
              seed: 'll-ss$_id',
              states: {if (focused) InkState.focused},
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
