import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A drop-down field: [child] (a [SelectTrigger]) shows the chosen item,
/// and [content] (a [SelectContent]) is the slip of paper with the
/// choices, set down over the trigger (or under it, in popper mode).
///
/// The value is yours with [value] and [onChanged], or the select's own
/// starting at [defaultValue]; the open state likewise with [open],
/// [defaultOpen] and [onOpenChange]. Enter, Space, the up and down arrows
/// or a tap open it; the arrows, Home and End move the highlighter,
/// letters jump by typeahead, Enter or Space choose, Escape closes it, and
/// focus goes back to the trigger. On the closed trigger, letters choose
/// directly.
///
/// The items are read from [content]'s children (and those of its
/// [SelectGroup]s), so the trigger can show the chosen one while closed.
///
/// ```dart
/// Select(
///   content: const SelectContent(
///     children: [
///       SelectItem(value: 'felt', child: Text('Felt tip')),
///       SelectItem(value: 'pencil', child: Text('Pencil')),
///     ],
///   ),
///   child: const SelectTrigger(
///     child: SelectValue(placeholder: 'Pick a pen'),
///   ),
/// )
/// ```
///
/// Mirrors `Select` in upstream `src/components/ui/select.tsx` (Radix
/// `Select.Root`).
class Select extends StatefulWidget {
  const Select({
    super.key,
    required this.content,
    required this.child,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.disabled = false,
  });

  /// The list.
  final SelectContent content;

  /// The trigger; a [SelectTrigger] or anything reading [Select.of].
  final Widget child;

  /// The chosen value; the select keeps its own when null.
  final String? value;

  /// The first value, when [value] is null.
  final String? defaultValue;

  /// Called with the chosen value (upstream `onValueChange`).
  final ValueChanged<String>? onChanged;

  /// Whether the list is open; the select keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// Disables the trigger and every choice.
  final bool disabled;

  /// The nearest select's controller.
  static SelectController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SelectScope>();
    if (scope == null) throw FlutterError('No Select above this widget.');
    return scope.controller;
  }

  /// The nearest select's controller, or null.
  static SelectController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SelectScope>()?.controller;

  /// The [SelectItem]s in [children], looking inside [SelectGroup]s.
  static List<SelectItem> itemsOf(List<Widget> children) => [
    for (final child in children)
      ...switch (child) {
        final SelectItem item => [item],
        final SelectGroup group => itemsOf(group.children),
        _ => const <SelectItem>[],
      },
  ];

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> with InkSeed {
  late String? _value = widget.defaultValue;
  late bool _open = widget.defaultOpen;
  String? _highlighted;
  final Object _group = Object();
  final FocusNode _triggerFocus = FocusNode(debugLabel: 'SelectTrigger');
  final GlobalKey _listKey = GlobalKey(debugLabel: 'SelectList');
  final ScrollController _scroll = ScrollController();
  final Map<String, GlobalKey> _rows = {};
  final NativeSelectTypeahead _typeahead = NativeSelectTypeahead();
  SelectPlacement? _placement;
  double _triggerWidth = 0;
  double _anchorY = 0;

  String? get _currentValue => widget.value ?? _value;

  bool get _isOpen => widget.open ?? _open;

  List<SelectItem> get _items => Select.itemsOf(widget.content.children);

  bool get _itemAligned =>
      widget.content.position == SelectPosition.itemAligned;

  @override
  void initState() {
    super.initState();
    if (_isOpen) _prepare();
  }

  @override
  void didUpdateWidget(Select oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasOpen = oldWidget.open ?? _open;
    if (_isOpen && !wasOpen) _prepare();
  }

  @override
  void dispose() {
    _triggerFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _prepare() {
    _placement = null;
    final items = _items;
    final chosen = items
        .where((item) => item.value == _currentValue && !item.disabled)
        .firstOrNull;
    _highlighted =
        chosen?.value ??
        items.where((item) => !item.disabled).firstOrNull?.value;
    _measureTriggerWidth();
  }

  double _measureTriggerWidth() {
    if (context.findRenderObject() case final RenderBox box when box.hasSize) {
      _triggerWidth = box.size.width;
    }
    return _triggerWidth;
  }

  void _setOpen(bool value) {
    if (value && widget.disabled) return;
    if (value == _isOpen) return;
    setState(() {
      if (value) _prepare();
      if (widget.open == null) _open = value;
    });
    widget.onOpenChange?.call(value);
  }

  void _select(String value) {
    final item = _items.where((item) => item.value == value).firstOrNull;
    if (item == null || item.disabled || widget.disabled) return;
    if (value != _currentValue) {
      if (widget.value == null) setState(() => _value = value);
      widget.onChanged?.call(value);
    }
    _setOpen(false);
  }

  void _highlight(String? value) {
    if (value == _highlighted) return;
    setState(() => _highlighted = value);
  }

  GlobalKey _rowKey(String value) =>
      _rows.putIfAbsent(value, () => GlobalKey(debugLabel: 'SelectItem'));

  int? _step(List<SelectItem> items, int from, int direction) {
    var index = from + direction;
    while (index >= 0 && index < items.length) {
      if (!items[index].disabled) return index;
      index += direction;
    }
    return null;
  }

  int? _typed(KeyEvent event, List<SelectItem> items, int current) {
    final char = event.character;
    if (char == null || char.trim().isEmpty || char.length != 1) return null;
    return _typeahead.find(
      char,
      [for (final item in items) item.label],
      current,
      enabled: (index) => !items[index].disabled,
    );
  }

  KeyEventResult _onTriggerKey(KeyEvent event) {
    if (event is KeyUpEvent || widget.disabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      _setOpen(true);
      return KeyEventResult.handled;
    }
    final items = _items;
    final current = items.indexWhere((item) => item.value == _currentValue);
    final next = _typed(event, items, current);
    if (next == null) return KeyEventResult.ignored;
    final value = items[next].value;
    if (value != _currentValue) {
      if (widget.value == null) setState(() => _value = value);
      widget.onChanged?.call(value);
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _onListKey(KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final items = _items;
    final current = items.indexWhere((item) => item.value == _highlighted);
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      if (_highlighted case final value?) _select(value);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) return KeyEventResult.handled;
    final next = switch (key) {
      LogicalKeyboardKey.arrowDown => _step(items, current, 1),
      LogicalKeyboardKey.arrowUp => _step(
        items,
        switch (current < 0) {
          true => items.length,
          false => current,
        },
        -1,
      ),
      LogicalKeyboardKey.home || LogicalKeyboardKey.pageUp => _step(
        items,
        -1,
        1,
      ),
      LogicalKeyboardKey.end || LogicalKeyboardKey.pageDown => _step(
        items,
        items.length,
        -1,
      ),
      _ => _typed(event, items, current),
    };
    if (next == null) return KeyEventResult.ignored;
    _highlight(items[next].value);
    _reveal(items[next].value);
    return KeyEventResult.handled;
  }

  void _reveal(String value) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final row = _rows[value]?.currentContext;
      if (!mounted || row == null || !row.mounted) return;
      Scrollable.ensureVisible(
        row,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
      Scrollable.ensureVisible(
        row,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
  }

  void _measure() {
    if (!_isOpen || _placement != null || !mounted) return;
    final trigger = context.findRenderObject();
    final overlay = Overlay.maybeOf(context)?.context.findRenderObject();
    final list = _listKey.currentContext?.findRenderObject();
    final target = _highlighted ?? _currentValue;
    final row = switch (target) {
      final value? => _rows[value]?.currentContext?.findRenderObject(),
      null => null,
    };
    if (trigger is! RenderBox ||
        overlay is! RenderBox ||
        list is! RenderBox ||
        !trigger.attached ||
        !list.attached) {
      return;
    }
    final rect = MatrixUtils.transformRect(
      trigger.getTransformTo(overlay),
      Offset.zero & trigger.size,
    );
    final (rowTop, rowHeight) = switch (row) {
      final RenderBox box when box.attached => (
        box.localToGlobal(Offset.zero, ancestor: list).dy,
        box.size.height,
      ),
      _ => (0.0, 0.0),
    };
    final placement = SelectPlacement.resolve(
      trigger: rect,
      bounds: overlay.size,
      listHeight: list.size.height,
      rowTop: rowTop,
      rowHeight: rowHeight,
      margin: SelectMetrics.margin,
      maxHeight: widget.content.maxHeight ?? double.infinity,
    );
    setState(() {
      _placement = placement;
      _triggerWidth = rect.width;
      _anchorY = placement.top - rect.top;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(
        math.min(placement.scroll, _scroll.position.maxScrollExtent),
      );
    });
  }

  Rect? _anchor(LooseleafThemeData theme) {
    if (!_itemAligned) return null;
    final inset =
        SelectMetrics.triggerStart -
        SelectMetrics.viewportPadding.resolve(theme.density) -
        SelectMetrics.itemInline.start;
    final y = _anchorY;
    return Rect.fromLTRB(inset, y, _triggerWidth - inset, y);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final content = widget.content;
    final open = _isOpen;
    final controller = SelectController(
      value: _currentValue,
      open: open,
      highlighted: _highlighted,
      disabled: widget.disabled,
      items: _items,
      groupId: _group,
      triggerFocus: _triggerFocus,
      listKey: _listKey,
      scroll: _scroll,
      triggerWidth: _measureTriggerWidth,
      placement: _placement,
      measuring: _itemAligned && _placement == null,
      seed: inkSeed(content.seed),
      setOpen: _setOpen,
      select: _select,
      highlight: _highlight,
      rowKey: _rowKey,
      onTriggerKey: _onTriggerKey,
      onListKey: _onListKey,
      measure: _measure,
    );
    final popper = !_itemAligned;
    return SelectScope(
      controller: controller,
      child: InkPopup(
        open: open,
        onOpenChange: _setOpen,
        side: content.side,
        align: switch (popper) {
          true => content.align,
          false => OverlayAlign.start,
        },
        sideOffset: switch (popper) {
          true => content.sideOffset,
          false => 0,
        },
        avoidCollisions: popper,
        collisionPadding: SelectMetrics.margin,
        anchor: _anchor(theme),
        modal: true,
        groupId: _group,
        popupBuilder: (context, position) => SelectScope(
          controller: controller,
          child: SelectContentScope(position: position, child: content),
        ),
        child: widget.child,
      ),
    );
  }
}
