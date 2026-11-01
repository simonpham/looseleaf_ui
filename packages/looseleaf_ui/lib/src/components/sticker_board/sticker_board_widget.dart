import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sticker_board/sticker_board.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A board you stick stickers on and arrange: drag one to move it, its
/// round handle to turn it, its square handle to size it; or focus it and
/// use the keyboard. A toolbar turns, sizes, restacks, duplicates, deletes
/// and exports.
///
/// The stickers are yours with [value] and [onValueChange], or the board's
/// own starting at [defaultValue]; add some with [StickerBoardOps.add].
/// The selection is yours with [selection] (a record, so `(id: null)`
/// means nothing selected) and [onSelectedIdChange], or the board's own
/// starting at [defaultSelectedId]. [children] lays out the parts (a
/// [StickerBoardCanvas] above a [StickerBoardToolbar] when null).
///
/// Keys on a focused sticker: arrows move it (Shift 32 px, Alt 1 px),
/// `[` and `]` (or R and Shift R) turn it (Shift for 15°), `+` and `-` size
/// it, `0` sets it upright at full size, Page Up and Page Down restack it
/// (Shift to the front or back), Delete removes it, Ctrl or ⌘ D duplicates
/// it and Escape lets go. Every change is announced.
///
/// [onExport] receives a [StickerBoardExport] (items, JSON, SVG, PNG).
///
/// ```dart
/// StickerBoard(
///   defaultValue: StickerBoardOps.add(const [], 'rocket'),
///   onExport: (data) => save(data.svg),
/// )
/// ```
///
/// Mirrors `StickerBoard` in upstream `src/components/ui/sticker-board.tsx`.
class StickerBoard extends StatefulWidget {
  const StickerBoard({
    super.key,
    this.value,
    this.defaultValue = const [],
    this.onValueChange,
    this.selection,
    this.defaultSelectedId,
    this.onSelectedIdChange,
    this.size = 96,
    this.minScale = 0.3,
    this.maxScale = 3,
    this.bounds = StickerBoardBounds.center,
    this.readOnly = false,
    this.disabled = false,
    this.label = 'Sticker board',
    this.onExport,
    this.children,
  });

  /// The stickers; the board keeps its own when null.
  final List<StickerBoardItem>? value;

  /// The starting stickers, when [value] is null.
  final List<StickerBoardItem> defaultValue;

  /// Called with every sticker after a change.
  final ValueChanged<List<StickerBoardItem>>? onValueChange;

  /// The selected sticker's id; the board keeps its own when null.
  final ({String? id})? selection;

  /// The starting selection, when [selection] is null.
  final String? defaultSelectedId;

  /// Called when the selection changes.
  final ValueChanged<String?>? onSelectedIdChange;

  /// The stickers' drawn size in pixels, before their scale.
  final double size;

  /// The smallest and largest scale.
  final double minScale;
  final double maxScale;

  /// How stickers are kept on the board.
  final StickerBoardBounds bounds;

  /// Shows the stickers without letting them change.
  final bool readOnly;

  /// Like [readOnly], faded to 70%.
  final bool disabled;

  /// The canvas's accessible name.
  final String label;

  /// Receives the board when exported.
  final ValueChanged<StickerBoardExport>? onExport;

  /// The parts; a canvas above a toolbar when null.
  final List<Widget>? children;

  /// Read to screen readers with an editable board.
  static const String help =
      'Stickers can be dragged. Focus one, then the arrow keys move it, '
      'Shift makes the steps bigger and Alt makes them one pixel. Left and '
      'right square brackets (or R and Shift R) turn it, plus and minus size '
      'it, Page Up and Page Down move it through the stack, Delete removes '
      'it and Escape lets go.';

  /// The arrow-key steps: plain, with Shift and with Alt.
  static const double step = 8;
  static const double bigStep = 32;
  static const double fineStep = 1;

  /// The turns in degrees: plain and with Shift.
  static const double turn = 5;
  static const double bigTurn = 15;

  /// The size factors: plain and with Shift.
  static const double zoom = 1.1;
  static const double bigZoom = 1.25;

  @override
  State<StickerBoard> createState() => StickerBoardState();
}

/// The state of a [StickerBoard]: its stickers, selection and edits.
class StickerBoardState extends State<StickerBoard> {
  late List<StickerBoardItem> _inner = widget.defaultValue;
  late List<StickerBoardItem> _latest = _items;
  late String? _innerSelected = widget.defaultSelectedId;
  String? _lifted;
  Timer? _said;
  final GlobalKey _canvasKey = GlobalKey();

  /// Takes focus after the focused sticker is deleted.
  final FocusNode surfaceFocus = FocusNode(
    debugLabel: 'sticker board surface',
    skipTraversal: true,
  );

  /// The canvas's size, once laid out.
  Size canvasSize = Size.zero;

  /// The key the canvas registers under, for [boardPoint].
  GlobalKey get canvasKey => _canvasKey;

  List<StickerBoardItem> get _items => wholeItems(widget.value ?? _inner);

  /// The stickers now, including changes not yet rebuilt.
  List<StickerBoardItem> get items => _latest;

  /// The selected sticker, if it is on the board.
  String? get selectedId {
    final id = widget.selection?.id ?? _innerSelectedIfOwn;
    if (id == null) return null;
    if (!_latest.any((s) => s.id == id)) return null;
    return id;
  }

  String? get _innerSelectedIfOwn => switch (widget.selection) {
    null => _innerSelected,
    _ => null,
  };

  /// Stickers can be moved and edited.
  bool get editable => !widget.readOnly && !widget.disabled;

  @override
  void dispose() {
    _said?.cancel();
    surfaceFocus.dispose();
    super.dispose();
  }

  /// Where [global] falls on the canvas, rounded, and whether it is on
  /// it; null before the canvas is laid out.
  ///
  /// Mirrors `boardPoint` in upstream `src/components/ui/sticker-board.tsx`.
  ({Offset point, bool inside})? boardPoint(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final local = box.globalToLocal(global);
    return (
      point: Offset(JsMath.round(local.dx), JsMath.round(local.dy)),
      inside: (Offset.zero & box.size).contains(local),
    );
  }

  /// Announces [message] to screen readers.
  void say(String message) {
    _said?.cancel();
    _said = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          message,
          Directionality.of(context),
        ),
      );
    });
  }

  /// Selects sticker [id], or nothing.
  void select(String? id) {
    if (widget.selection == null) setState(() => _innerSelected = id);
    widget.onSelectedIdChange?.call(id);
  }

  /// Raises sticker [id] over every other while it is dragged.
  void lift(String? id) {
    if (_lifted == id) return;
    setState(() => _lifted = id);
  }

  /// Replaces every sticker with [next], announcing [message].
  void commit(List<StickerBoardItem> next, [String? message]) {
    _latest = next;
    if (widget.value == null) setState(() => _inner = next);
    widget.onValueChange?.call(next);
    if (message != null) say(message);
  }

  StickerBoardItem? _find(String id) {
    for (final s in _latest) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Sticker [id]'s label.
  String nameOf(String id) => switch (_find(id)) {
    final it? => stickerLabel(it.name),
    null => id,
  };

  /// Replaces sticker [id] with [change] of it, announcing [message].
  void patch(
    String id,
    StickerBoardItem Function(StickerBoardItem item) change, [
    String? message,
  ]) => commit([
    for (final s in _latest)
      switch (s.id == id) {
        true => change(s),
        false => s,
      },
  ], message);

  /// Takes sticker [id] off the board.
  void remove(String id) {
    if (_find(id) == null) return;
    final name = nameOf(id);
    commit([
      for (final s in _latest)
        if (s.id != id) s,
    ], '$name removed.');
    select(null);
  }

  /// Adds a copy of sticker [id] 20 px down and right, and selects it.
  void duplicate(String id) {
    final it = _find(id);
    if (it == null) return;
    final next = StickerBoardOps.add(
      _latest,
      it.name,
      x: it.x + 20,
      y: it.y + 20,
      rot: it.rot,
      scale: it.scale,
    );
    commit(next, '${nameOf(id)} duplicated.');
    select(next.last.id);
  }

  /// Moves sticker [id] [how] through the stack.
  void reorder(String id, StickerReorder how) {
    final next = StickerBoardOps.reorder(_latest, id, how);
    if (identical(next, _latest)) {
      final where = switch (how) {
        StickerReorder.forward || StickerReorder.front => 'on top',
        StickerReorder.backward || StickerReorder.back => 'at the back',
      };
      say('${nameOf(id)} is already $where.');
      return;
    }
    commit(next, '${nameOf(id)} ${how.said}.');
  }

  /// Turns sticker [id] by [deg] degrees.
  void turn(String id, double deg) {
    final it = _find(id);
    if (it == null) return;
    final rot = StickerBoardOps.turnTo(it.rot + deg);
    patch(
      id,
      (s) => s.copyWith(rot: rot),
      '${nameOf(id)} turned to ${JsMath.numberToString(rot)} degrees.',
    );
  }

  /// Sizes sticker [id] by [factor], within the board's scales.
  void resize(String id, double factor) {
    final it = _find(id);
    if (it == null) return;
    final scale = StickerBoardOps.round2(
      it.scale * factor,
    ).clamp(widget.minScale, widget.maxScale);
    if (scale == it.scale) {
      final how = switch (factor > 1) {
        true => 'big',
        false => 'small',
      };
      say('${nameOf(id)} is as $how as it goes.');
      return;
    }
    patch(
      id,
      (s) => s.copyWith(scale: scale),
      '${nameOf(id)} at ${JsMath.round(scale * 100).toInt()} percent.',
    );
  }

  /// Hands the board to [StickerBoard.onExport].
  void exportBoard() {
    final width = switch (canvasSize.width) {
      0 => 640.0,
      final w => w,
    };
    final height = switch (canvasSize.height) {
      0 => 400.0,
      final h => h,
    };
    widget.onExport?.call(
      StickerBoardExport(
        items: _latest,
        width: width,
        height: height,
        size: widget.size,
        theme: LooseleafTheme.of(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _latest = _items;
    final board = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d12,
      children:
          widget.children ??
          const [StickerBoardCanvas(), StickerBoardToolbar()],
    );
    return StickerBoardScope(
      board: this,
      items: _latest,
      selectedId: selectedId,
      editable: editable,
      lifted: _lifted,
      child: Opacity(
        opacity: switch (widget.disabled) {
          true => 0.7,
          false => 1,
        },
        child: board,
      ),
    );
  }
}
