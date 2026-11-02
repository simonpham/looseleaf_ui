import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_controller.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_filter.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_item_data.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';

/// Builds the polite status a [Combobox.multiple] speaks when values are
/// [added] or [removed] (labels).
typedef ComboboxAnnounce =
    String Function(
      List<String> added,
      List<String> removed,
    );

/// A searchable choice, shadcn's combobox: a [ComboboxTrigger] that opens a
/// popup with a search box and a list, a typing field ([ComboboxInput] on
/// its own), or a field of chips ([ComboboxChips]) for several values.
///
/// The root holds the state; compose the parts under it:
///
/// ```dart
/// Combobox(
///   items: frameworks,
///   value: framework,
///   onChanged: (value) => setState(() => framework = value),
///   label: 'Framework',
///   child: const Column(children: [
///     ComboboxTrigger(child: ComboboxValue(placeholder: 'Select framework…')),
///     ComboboxContent(children: [
///       ComboboxInput(placeholder: 'Search framework…'),
///       ComboboxList(children: [ComboboxEmpty(child: Text('No framework found.'))]),
///     ]),
///   ]),
/// )
/// ```
///
/// Mirrors `Combobox` in upstream `src/components/ui/combobox.tsx`.
class Combobox extends StatefulWidget {
  /// A combobox choosing one value.
  const Combobox({
    super.key,
    required this.child,
    String? value,
    ValueChanged<String?>? onChanged,
    String? defaultValue,
    this.items = const [],
    this.open,
    this.onOpenChange,
    this.onInputValueChange,
    this.filter = comboboxDefaultFilter,
    this.loop = false,
    this.loading = false,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.label,
  }) : multiple = false,
       _value = value,
       _onChanged = onChanged,
       _defaultValue = defaultValue,
       _defaultValues = const [],
       _uncontrolled =
           defaultValue != null || (value == null && onChanged == null),
       values = null,
       onValuesChanged = null,
       announce = null;

  /// A combobox choosing several values, shown as chips.
  const Combobox.multiple({
    super.key,
    required this.child,
    this.values,
    this.onValuesChanged,
    List<String> defaultValues = const [],
    this.items = const [],
    this.open,
    this.onOpenChange,
    this.onInputValueChange,
    this.filter = comboboxDefaultFilter,
    this.loop = false,
    this.loading = false,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.label,
    this.announce,
  }) : multiple = true,
       _value = null,
       _onChanged = null,
       _defaultValue = null,
       _defaultValues = defaultValues,
       _uncontrolled = values == null;

  /// The parts: a trigger or field and a [ComboboxContent].
  final Widget child;

  /// Whether several values can be chosen.
  final bool multiple;

  final String? _value;
  final ValueChanged<String?>? _onChanged;

  /// What an uncontrolled combobox starts with (upstream `defaultValue`).
  final String? _defaultValue;
  final List<String> _defaultValues;

  /// Whether the combobox keeps its own value: a single one given a
  /// `defaultValue` (or neither a value nor `onChanged`), a multiple one
  /// given no [values].
  final bool _uncontrolled;

  /// The chosen values of a [Combobox.multiple]; null keeps its own,
  /// starting at `defaultValues`.
  final List<String>? values;

  /// Called with the next values of a [Combobox.multiple].
  final ValueChanged<List<String>>? onValuesChanged;

  /// The choices; [ComboboxList] renders them when given no children.
  final List<ComboboxItemData> items;

  /// Opens the popup from outside; null leaves it to the combobox.
  final bool? open;

  final ValueChanged<bool>? onOpenChange;

  /// Called with the search text as it changes (async search).
  final ValueChanged<String>? onInputValueChange;

  /// Scores rows against the search; null keeps every row (upstream
  /// `shouldFilter={false}`).
  final ComboboxFilter? filter;

  /// Whether the arrow keys wrap around.
  final bool loop;

  /// Shows [ComboboxLoading] and hides [ComboboxEmpty].
  final bool loading;

  final bool disabled;

  /// Shows the choice but does not open or change.
  final bool readOnly;

  /// Draws the field in red pencil.
  final bool invalid;

  /// The list's accessible name.
  final String? label;

  /// The status spoken when chips change; null says "X selected" /
  /// "X removed".
  final ComboboxAnnounce? announce;

  /// The state of the nearest combobox, like upstream `useCombobox()`.
  static ComboboxController of(BuildContext context) =>
      ComboboxScope.of(context).controller;

  @override
  State<Combobox> createState() => _ComboboxState();
}

class _ComboboxState extends State<Combobox> {
  late final ComboboxController _controller = ComboboxController(
    multiple: widget.multiple,
    onValueChanged: _onValueChanged,
    onOpenChanged: (open) => widget.onOpenChange?.call(open),
  );
  int _revision = 0;
  late List<String> _own = switch (widget.multiple) {
    true => widget._defaultValues,
    false => [?widget._defaultValue],
  };

  List<String> get _value => switch ((widget._uncontrolled, widget.multiple)) {
    (true, _) => _own,
    (false, true) => widget.values ?? const [],
    (false, false) => [?widget._value],
  };

  @override
  void initState() {
    super.initState();
    _configure();
    if (widget.open ?? false) _controller.setOpen(true);
    _controller.addListener(_onChange);
  }

  @override
  void didUpdateWidget(Combobox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _revision++;
    final before = _controller.value;
    _configure();
    if (!_same(before, _controller.value)) {
      _controller.valueChanged();
      _announce(before, _controller.value);
    }
    final open = widget.open;
    if (open != null && open != _controller.open) _controller.setOpen(open);
  }

  static bool _same(List<String> a, List<String> b) =>
      a.length == b.length &&
      [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((same) => same);

  void _configure() {
    _controller
      ..multiple = widget.multiple
      ..value = _value
      ..items = widget.items
      ..disabled = widget.disabled
      ..readOnly = widget.readOnly
      ..invalid = widget.invalid
      ..loading = widget.loading
      ..label = widget.label
      ..filter = widget.filter
      ..loop = widget.loop
      ..onQueryChanged = widget.onInputValueChange;
  }

  void _onValueChanged(List<String> next) {
    if (widget._uncontrolled) _keep(next);
    if (widget.multiple) {
      widget.onValuesChanged?.call(next);
      return;
    }
    widget._onChanged?.call(next.firstOrNull);
  }

  void _keep(List<String> next) {
    final before = _controller.value;
    if (_same(before, next)) return;
    _controller.value = next;
    setState(() {
      _own = next;
      _revision++;
    });
    scheduleMicrotask(() {
      if (!mounted) return;
      _controller.valueChanged();
      _announce(before, next);
    });
  }

  void _announce(List<String> before, List<String> after) {
    if (!widget.multiple) return;
    final added = [
      for (final value in after)
        if (!before.contains(value)) _controller.labelFor(value),
    ];
    final removed = [
      for (final value in before)
        if (!after.contains(value)) _controller.labelFor(value),
    ];
    if (added.isEmpty && removed.isEmpty) return;
    final message =
        widget.announce?.call(added, removed) ??
        [
          if (added.isNotEmpty) '${added.join(', ')} selected',
          if (removed.isNotEmpty) '${removed.join(', ')} removed',
        ].join('. ');
    inkAnnounce(context, message);
  }

  void _onChange() => setState(() => _revision++);

  @override
  void dispose() {
    _controller
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ComboboxScope(
    controller: _controller,
    revision: _revision,
    child: widget.child,
  );
}
