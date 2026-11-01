import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/prompt_input/prompt_input_types.dart';

/// One choice in the open suggestions list.
typedef PromptInputOption = ({VoidCallback? onSelect, bool disabled});

/// A [PromptInput]'s live state for its parts: the text, the status, the
/// trigger being typed, the suggestions and the actions on them, like
/// upstream `usePromptInput()`.
///
/// Read it with [PromptInputModel.of]; the parts rebuild when it changes.
class PromptInputModel extends ChangeNotifier {
  PromptInputModel({
    required this.controller,
    required this.focusNode,
  }) {
    controller.addListener(_onText);
  }

  /// The text, its selection and its composing range.
  final TextEditingController controller;

  /// The textarea's focus.
  final FocusNode focusNode;

  PromptInputStatus _status = PromptInputStatus.ready;
  var _disabled = false;
  var _allowEmpty = false;
  var _lockWhileStreaming = false;
  var _submitOn = PromptInputSubmitOn.enter;
  List<PromptInputTrigger> _triggers = const [];
  VoidCallback? _onSubmit;
  VoidCallback? _onStop;
  ValueChanged<PromptInputActiveTrigger?>? _onTriggerChange;

  var _flight = 0;
  ({int from, String char})? _dismissed;
  PromptInputActiveTrigger? _lastTrigger;
  List<PromptInputOption> _options = const [];
  Object? _owner;
  int? _active;
  String _lastText = '';
  int _lastCaret = -1;

  /// The text.
  String get value => controller.text;

  PromptInputStatus get status => _status;

  /// A request is in flight: the submit stops it.
  bool get busy => _status.busy;

  bool get disabled => _disabled;
  bool get allowEmpty => _allowEmpty;

  /// The textarea is read-only while [busy].
  bool get lockWhileStreaming => _lockWhileStreaming;

  PromptInputSubmitOn get submitOn => _submitOn;

  /// How many times a message was sent; the paper plane flies on each.
  int get flight => _flight;

  /// Whether there is nothing to send.
  bool get empty => !_allowEmpty && value.trim().isEmpty;

  /// The trigger word being typed, unless Escape dismissed it.
  PromptInputActiveTrigger? get trigger {
    final found = _found();
    final dismissed = _dismissed;
    if (found == null || dismissed == null) return found;
    if (dismissed.from == found.from && dismissed.char == found.char) {
      return null;
    }
    return found;
  }

  /// Whether a suggestions list with a choice is open.
  bool get optionsOpen =>
      trigger != null && _options.any((option) => !option.disabled);

  /// The highlighted suggestion's index.
  int? get activeIndex => _active;

  /// Applies the [PromptInput]'s props; called on every build.
  void configure({
    required PromptInputStatus status,
    required bool disabled,
    required bool allowEmpty,
    required bool lockWhileStreaming,
    required PromptInputSubmitOn submitOn,
    required List<PromptInputTrigger> triggers,
    required VoidCallback onSubmit,
    required VoidCallback? onStop,
    required ValueChanged<PromptInputActiveTrigger?>? onTriggerChange,
  }) {
    _status = status;
    _disabled = disabled;
    _allowEmpty = allowEmpty;
    _lockWhileStreaming = lockWhileStreaming;
    _submitOn = submitOn;
    _triggers = triggers;
    _onSubmit = onSubmit;
    _onStop = onStop;
    _onTriggerChange = onTriggerChange;
  }

  /// Sends the text when there is something to send and nothing in flight.
  void submit() {
    if (_disabled || busy || empty) return;
    _onSubmit?.call();
  }

  /// Marks a send: the plane flies, the caret goes home, focus returns.
  void sent({required bool clear}) {
    _flight++;
    if (clear) controller.clear();
    focus();
    notifyListeners();
  }

  /// Stops the request in flight.
  void stop() => _onStop?.call();

  /// Focuses the textarea.
  void focus() => focusNode.requestFocus();

  /// Replaces the trigger word with [text] (and a space unless [space] is
  /// false or one follows), leaving the caret after it.
  void replaceTrigger(String text, {bool space = true}) {
    final active = trigger;
    if (active == null) return;
    final before = value.substring(0, active.from);
    final after = value.substring(active.to);
    final insert = switch (space && !after.startsWith(' ')) {
      true => '$text ',
      false => text,
    };
    final caret = before.length + insert.length;
    controller.value = TextEditingValue(
      text: '$before$insert$after',
      selection: TextSelection.collapsed(offset: caret),
    );
    focus();
  }

  /// Closes the suggestions for the trigger word being typed (Escape).
  void dismissTrigger() {
    final active = trigger;
    if (active == null) return;
    _dismissed = (from: active.from, char: active.char);
    _triggerChanged();
    notifyListeners();
  }

  /// Publishes the open list's choices; called by the suggestions list
  /// [owner] while it shows.
  void setOptions(Object owner, List<PromptInputOption> options) {
    _owner = owner;
    _options = options;
    final active = _active;
    final valid =
        active != null && active < options.length && !options[active].disabled;
    if (valid) return;
    final first = options.indexWhere((option) => !option.disabled);
    _active = switch (first) {
      -1 => null,
      _ => first,
    };
  }

  /// Drops [owner]'s choices once its list closes.
  void clearOptions(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    _options = const [];
    _active = null;
  }

  /// Highlights suggestion [index] (the pointer moved onto it).
  void setActive(int index) {
    if (_active == index) return;
    _active = index;
    notifyListeners();
  }

  /// Moves the highlight [step] choices, wrapping round.
  void move(int step) {
    final enabled = [
      for (final (index, option) in _options.indexed)
        if (!option.disabled) index,
    ];
    if (enabled.isEmpty) return;
    final at = enabled.indexOf(_active ?? -1);
    final next = (at + step) % enabled.length;
    _active =
        enabled[switch (at) {
          -1 when step < 0 => enabled.length - 1,
          -1 => 0,
          _ => next,
        }];
    notifyListeners();
  }

  /// Picks the highlighted (or first) choice; false when there is none.
  bool pickActive() {
    final active = _active;
    final option = switch (active) {
      final index? when index < _options.length => _options[index],
      _ => _options.where((option) => !option.disabled).firstOrNull,
    };
    if (option == null || option.disabled) return false;
    option.onSelect?.call();
    return true;
  }

  PromptInputActiveTrigger? _found() {
    final caret = controller.selection.baseOffset;
    return PromptInputActiveTrigger.detect(value, caret, _triggers);
  }

  void _onText() {
    final caret = controller.selection.baseOffset;
    if (controller.text == _lastText && caret == _lastCaret) return;
    _lastText = controller.text;
    _lastCaret = caret;
    final found = _found();
    final dismissed = _dismissed;
    final stale =
        dismissed != null &&
        (found == null ||
            found.from != dismissed.from ||
            found.char != dismissed.char);
    if (stale) _dismissed = null;
    _triggerChanged();
    notifyListeners();
  }

  void _triggerChanged() {
    final next = trigger;
    if (next == _lastTrigger) return;
    _lastTrigger = next;
    _onTriggerChange?.call(next);
  }

  @override
  void dispose() {
    controller.removeListener(_onText);
    super.dispose();
  }

  /// The nearest [PromptInput]'s model.
  static PromptInputModel of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<PromptInputScope>();
    if (scope?.notifier case final model?) return model;
    throw FlutterError('PromptInputModel.of() called outside a PromptInput.');
  }
}

/// Hands a [PromptInput]'s model to its parts.
class PromptInputScope extends InheritedNotifier<PromptInputModel> {
  const PromptInputScope({
    super.key,
    required PromptInputModel model,
    required super.child,
  }) : super(notifier: model);
}
