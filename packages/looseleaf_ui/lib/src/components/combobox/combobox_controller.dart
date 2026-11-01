import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_filter.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_item_data.dart';

/// How the combobox's own input sits: none (a [ComboboxTrigger] opens a
/// search popup), a single-value field, or a chips field.
enum ComboboxFieldMode { none, single, chips }

/// A row the list knows about: registered by each [ComboboxItem] (and
/// [ComboboxCreate]) while it is built.
class ComboboxEntry {
  ComboboxEntry({
    required this.value,
    required this.label,
    required this.keywords,
    required this.disabled,
    required this.group,
    required this.order,
    this.pinned,
    this.onSelect,
  });

  String value;
  String label;
  List<String> keywords;
  bool disabled;

  /// The [ComboboxGroup] holding the row, if any.
  Object? group;

  /// Registration order: the list order the arrow keys follow.
  final int order;

  /// Shown (true) or hidden (false) whatever the search, like the create
  /// row; null follows the filter.
  bool? pinned;

  /// What choosing the row does; selecting [value] when null.
  VoidCallback? onSelect;

  /// The row's build context, to scroll it into view.
  BuildContext? context;
}

/// The state every combobox part shares, like upstream `useCombobox()`: the
/// chosen values, the popup, the search, the highlighted row and the rows
/// the list holds.
///
/// [Combobox] owns it; parts read it with [Combobox.of].
class ComboboxController extends ChangeNotifier {
  ComboboxController({
    required this.multiple,
    required this.onValueChanged,
    required this.onOpenChanged,
  });

  /// Whether several values can be chosen (chips).
  bool multiple;

  /// The chosen values; at most one when not [multiple].
  List<String> value = const [];

  /// The items given to the root.
  List<ComboboxItemData> items = const [];

  bool disabled = false;
  bool readOnly = false;
  bool invalid = false;
  bool loading = false;

  /// The accessible name of the list.
  String? label;

  /// Scores rows against the search; null shows every row.
  ComboboxFilter? filter = comboboxDefaultFilter;

  /// Whether the arrow keys wrap around at the ends.
  bool loop = false;

  /// Called with the next chosen values.
  final ValueChanged<List<String>> onValueChanged;

  /// Called with the next open state.
  final ValueChanged<bool> onOpenChanged;

  /// Called with the search text as it changes.
  ValueChanged<String>? onQueryChanged;

  bool _open = false;
  String _query = '';
  bool _dirty = false;
  String? _active;
  ComboboxFieldMode _fieldMode = ComboboxFieldMode.none;
  final Map<String, ComboboxEntry> _entries = {};
  final Map<String, String> _seen = {};
  int _order = 0;
  bool _notifyScheduled = false;
  bool _disposed = false;

  /// Links the popup to the field or trigger it hangs from.
  final LayerLink link = LayerLink();

  /// The anchor's width, for the popup's; reported after each layout.
  final ValueNotifier<double?> anchorWidth = ValueNotifier(null);

  /// The field's or search box's text.
  final TextEditingController text = TextEditingController();

  /// The input that holds focus while the popup is open.
  final FocusNode inputFocus = FocusNode(debugLabel: 'combobox input');

  /// The [ComboboxTrigger]'s node, refocused when the popup closes.
  final FocusNode triggerFocus = FocusNode(debugLabel: 'combobox trigger');

  /// Groups the anchor and the popup, so a tap on one is not outside the
  /// other.
  Object get tapGroup => this;

  bool get open => _open;
  String get query => _query;

  /// Whether the field's text was typed since the last choice; a single
  /// field shows every row until it is.
  bool get dirty => _dirty;

  /// The highlighted row's value.
  String? get active => _active;

  ComboboxFieldMode get fieldMode => _fieldMode;

  /// Set by [ComboboxInput] (outside the popup) and [ComboboxChips].
  set fieldMode(ComboboxFieldMode mode) {
    if (_fieldMode == mode) return;
    _fieldMode = mode;
    _later();
  }

  /// [value]'s label: the item's, else the label a row registered, else
  /// [value] itself.
  String labelFor(String value) {
    for (final item in items) {
      if (item.value == value) return item.label;
    }
    return _seen[value] ?? value;
  }

  /// Whether some item has [text] as its value or label.
  bool hasItem(String text) {
    final wanted = text.trim().toLowerCase();
    if (wanted.isEmpty) return false;
    for (final item in items) {
      if (item.value.toLowerCase() == wanted) return true;
      if (item.label.toLowerCase() == wanted) return true;
    }
    for (final MapEntry(:key, :value) in _seen.entries) {
      if (key.toLowerCase() == wanted || value.toLowerCase() == wanted) {
        return true;
      }
    }
    return false;
  }

  /// Opens or closes the popup; closing clears the search.
  void setOpen(bool next) {
    if (next && (readOnly || disabled)) return;
    if (_open == next) return;
    _open = next;
    if (!next) {
      _setQuery('');
      _dirty = false;
      _syncFieldText();
    }
    if (next) _active = _initialActive();
    onOpenChanged(next);
    notifyListeners();
  }

  /// Sets the search from typing in an input.
  void type(String query, {bool dirty = true}) {
    _setQuery(query);
    _dirty = _dirty || dirty;
    if (!_open) {
      setOpen(true);
      return;
    }
    _active = _firstVisible();
    notifyListeners();
  }

  void _setQuery(String query) {
    if (_query == query) return;
    _query = query;
    onQueryChanged?.call(query);
  }

  /// Chooses [item]: toggles it in a [multiple] combobox, otherwise picks it
  /// and closes.
  void select(String item) {
    if (readOnly) return;
    if (multiple) {
      onValueChanged(switch (value.contains(item)) {
        true => [
          for (final chosen in value)
            if (chosen != item) chosen,
        ],
        false => [...value, item],
      });
      _setQuery('');
      _dirty = false;
      text.clear();
      notifyListeners();
      return;
    }
    onValueChanged([item]);
    _dirty = false;
    setOpen(false);
    _syncFieldText(chosen: item);
    _refocus();
  }

  /// Takes [item] out of the chosen values.
  void remove(String item) {
    if (readOnly) return;
    onValueChanged([
      for (final chosen in value)
        if (chosen != item) chosen,
    ]);
  }

  /// Clears the choice and the search.
  void clear() {
    if (readOnly) return;
    onValueChanged(const []);
    _setQuery('');
    _dirty = false;
    text.clear();
    notifyListeners();
  }

  void _refocus() {
    if (_fieldMode != ComboboxFieldMode.none) return;
    triggerFocus.requestFocus();
  }

  /// Puts the chosen label in a single field when the user is not typing.
  void _syncFieldText({String? chosen}) {
    if (_fieldMode != ComboboxFieldMode.single || _dirty) return;
    final shown = switch (chosen ?? value.firstOrNull) {
      final picked? => labelFor(picked),
      null => '',
    };
    if (text.text == shown) return;
    text.value = TextEditingValue(
      text: shown,
      selection: TextSelection.collapsed(offset: shown.length),
    );
  }

  /// Called by the root when its value changes from outside.
  void valueChanged() => _syncFieldText();

  /// Registers a row; the returned entry is updated in place by the row.
  ComboboxEntry register({
    required String value,
    required String label,
    required List<String> keywords,
    required bool disabled,
    required Object? group,
    bool? pinned,
    VoidCallback? onSelect,
  }) {
    final entry = ComboboxEntry(
      value: value,
      label: label,
      keywords: keywords,
      disabled: disabled,
      group: group,
      order: _order++,
      pinned: pinned,
      onSelect: onSelect,
    );
    _entries[value] = entry;
    if (pinned == null) _seen[value] = label;
    _later();
    return entry;
  }

  void unregister(ComboboxEntry entry) {
    if (!identical(_entries[entry.value], entry)) return;
    _entries.remove(entry.value);
    _later();
  }

  void _later() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (_disposed) return;
      if (_active == null || !visible(_active ?? '')) {
        _active = _initialActive();
      }
      notifyListeners();
    });
  }

  /// Whether the filter keeps the row for [value].
  bool visible(String value) {
    final entry = _entries[value];
    if (entry == null) return false;
    return entry.pinned ?? score(entry) > 0;
  }

  /// The filter's score of [entry] against the search.
  double score(ComboboxEntry entry) {
    final filter = this.filter;
    if (filter == null) return 1;
    if (_fieldMode == ComboboxFieldMode.single && !_dirty) return 1;
    return filter(entry.value, _query, [entry.label, ...entry.keywords]);
  }

  /// The visible rows in list order.
  List<ComboboxEntry> get visibleEntries {
    final shown = [
      for (final entry in _entries.values)
        if (visible(entry.value)) entry,
    ]..sort((a, b) => a.order.compareTo(b.order));
    return shown;
  }

  /// Whether any row (not the create row) is visible.
  bool get hasResults => visibleEntries.any((entry) => entry.pinned == null);

  /// Whether [group] holds a visible row, or has not registered any yet.
  bool groupVisible(Object group) {
    final rows = [
      for (final entry in _entries.values)
        if (identical(entry.group, group)) entry,
    ];
    return rows.isEmpty || rows.any((entry) => visible(entry.value));
  }

  String? _firstVisible() {
    for (final entry in visibleEntries) {
      if (!entry.disabled) return entry.value;
    }
    return null;
  }

  String? _initialActive() {
    for (final chosen in value) {
      if (visible(chosen) && !(_entries[chosen]?.disabled ?? true)) {
        return chosen;
      }
    }
    return _firstVisible();
  }

  /// Highlights [value] (pointer hover).
  void highlight(String value) {
    if (_active == value) return;
    _active = value;
    notifyListeners();
  }

  void _move(int step) {
    final rows = [
      for (final entry in visibleEntries)
        if (!entry.disabled) entry,
    ];
    if (rows.isEmpty) return;
    final current = rows.indexWhere((entry) => entry.value == _active);
    var next = current + step;
    if (current < 0) {
      next = switch (step > 0) {
        true => 0,
        false => rows.length - 1,
      };
    }
    if (next < 0 || next >= rows.length) {
      if (!loop) return;
      next = next % rows.length;
    }
    _active = rows[next].value;
    notifyListeners();
    _reveal(rows[next]);
  }

  void _edge(bool last) {
    final rows = [
      for (final entry in visibleEntries)
        if (!entry.disabled) entry,
    ];
    if (rows.isEmpty) return;
    final target = switch (last) {
      true => rows.last,
      false => rows.first,
    };
    _active = target.value;
    notifyListeners();
    _reveal(target);
  }

  void _reveal(ComboboxEntry entry) {
    final context = entry.context;
    if (context == null || !context.mounted) return;
    Scrollable.ensureVisible(context, alignmentPolicy: _policy);
  }

  static const ScrollPositionAlignmentPolicy _policy =
      ScrollPositionAlignmentPolicy.keepVisibleAtEnd;

  /// Chooses the highlighted row.
  void chooseActive() {
    final active = _active;
    if (active == null) return;
    final entry = _entries[active];
    if (entry == null || entry.disabled || !visible(active)) return;
    final onSelect = entry.onSelect;
    if (onSelect != null) {
      onSelect();
      return;
    }
    select(active);
  }

  /// The list keys of an input: the arrows open the list and move the
  /// highlight, Home and End jump, Enter chooses, Escape closes, and
  /// Backspace in an empty chips input takes the last chip back.
  KeyEventResult handleKey(KeyEvent event) {
    if (event is KeyUpEvent || disabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace &&
        _fieldMode == ComboboxFieldMode.chips &&
        text.text.isEmpty &&
        value.isNotEmpty) {
      remove(value.last);
      return KeyEventResult.handled;
    }
    final vertical =
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp;
    if (!_open) {
      if (!vertical) return KeyEventResult.ignored;
      setOpen(true);
      return KeyEventResult.handled;
    }
    switch (key) {
      case LogicalKeyboardKey.arrowDown:
        _move(1);
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
      case LogicalKeyboardKey.home:
        _edge(false);
      case LogicalKeyboardKey.end:
        _edge(true);
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.numpadEnter:
        chooseActive();
      case LogicalKeyboardKey.escape:
        setOpen(false);
        _refocus();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _disposed = true;
    anchorWidth.dispose();
    text.dispose();
    inputFocus.dispose();
    triggerFocus.dispose();
    super.dispose();
  }
}
