import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/calendar_planner/calendar_planner.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The taped form that adds an event or changes one: what, which day,
/// from and to, what sort and notes, checked before it is written down.
///
/// Mirrors `EventDialog` in upstream
/// `src/blocks/calendar-planner/components/calendar-planner-event-dialog.tsx`.
class CalendarPlannerEventDialog extends StatefulWidget {
  const CalendarPlannerEventDialog({
    super.key,
    required this.event,
    required this.date,
    required this.onSave,
    required this.onDelete,
  });

  /// The event to change; null for a new one.
  final CalendarPlannerEvent? event;

  /// The day a new event starts on.
  final String date;

  /// Called with the draft (its id is the edited event's, or empty).
  final ValueChanged<CalendarPlannerEvent> onSave;
  final ValueChanged<CalendarPlannerEvent> onDelete;

  @override
  State<CalendarPlannerEventDialog> createState() =>
      _CalendarPlannerEventDialogState();
}

class _CalendarPlannerEventDialogState
    extends State<CalendarPlannerEventDialog> {
  late final _title = TextEditingController(text: widget.event?.title);
  late final _date = TextEditingController(
    text: widget.event?.date ?? widget.date,
  );
  late final _start = TextEditingController(
    text: widget.event?.start ?? '09:00',
  );
  late final _end = TextEditingController(text: widget.event?.end ?? '10:00');
  late final _notes = TextEditingController(text: widget.event?.notes);
  late CalendarPlannerKind _kind =
      widget.event?.kind ?? CalendarPlannerKind.studio;
  final _titleFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _startFocus = FocusNode();
  final _endFocus = FocusNode();
  final _notesFocus = FocusNode();
  ({String? title, String? date, String? end}) _errors = (
    title: null,
    date: null,
    end: null,
  );

  static final _isoDay = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  @override
  void dispose() {
    for (final controller in [_title, _date, _start, _end, _notes]) {
      controller.dispose();
    }
    for (final node in [
      _titleFocus,
      _dateFocus,
      _startFocus,
      _endFocus,
      _notesFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    final errors = (
      title: switch (title.isEmpty) {
        true => 'Give the event a name.',
        false => null,
      },
      date: switch (_isoDay.hasMatch(_date.text)) {
        true => null,
        false => 'Pick a day.',
      },
      end: switch (_end.text.compareTo(_start.text) <= 0) {
        true => 'The end has to come after the start.',
        false => null,
      },
    );
    setState(() => _errors = errors);
    final first = switch (errors) {
      (title: _?, date: _, end: _) => _titleFocus,
      (title: null, date: _?, end: _) => _dateFocus,
      (title: null, date: null, end: _?) => _endFocus,
      _ => null,
    };
    if (first != null) {
      first.requestFocus();
      return;
    }
    widget.onSave(
      CalendarPlannerEvent(
        id: widget.event?.id ?? '',
        title: title,
        date: _date.text,
        start: _start.text,
        end: _end.text,
        kind: _kind,
        notes: _notes.text,
      ),
    );
  }

  Widget _error(String? message) => switch (message) {
    null => const SizedBox.shrink(),
    final text => FieldError(child: Text(text)),
  };

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return DialogContent(
      tape: PaperTape.both,
      tapeKind: TapeKind.washiDots,
      children: [
        DialogHeader(
          children: [
            DialogTitle(
              Text(switch (event) {
                null => 'A new event',
                _ => 'Change the event',
              }),
            ),
            DialogDescription(
              Text(switch (event) {
                null => 'Write it on the day so it does not slip.',
                _ => 'Rewrite it, or cross it out.',
              }),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            Field(
              invalid: _errors.title != null,
              children: [
                FieldLabel(
                  focusNode: _titleFocus,
                  child: const Text('What is happening?'),
                ),
                Input(
                  controller: _title,
                  focusNode: _titleFocus,
                  invalid: _errors.title != null,
                  semanticLabel: 'What is happening?',
                  onSubmitted: (_) => _submit(),
                ),
                _error(_errors.title),
              ],
            ),
            Field(
              invalid: _errors.date != null,
              children: [
                FieldLabel(
                  focusNode: _dateFocus,
                  child: const Text('Which day?'),
                ),
                Input(
                  controller: _date,
                  focusNode: _dateFocus,
                  invalid: _errors.date != null,
                  placeholder: 'yyyy-mm-dd',
                  semanticLabel: 'Which day?',
                  keyboardType: TextInputType.datetime,
                ),
                _error(_errors.date),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                Expanded(
                  child: Field(
                    children: [
                      FieldLabel(
                        focusNode: _startFocus,
                        child: const Text('From'),
                      ),
                      Input(
                        controller: _start,
                        focusNode: _startFocus,
                        placeholder: 'hh:mm',
                        semanticLabel: 'From',
                        keyboardType: TextInputType.datetime,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Field(
                    invalid: _errors.end != null,
                    children: [
                      FieldLabel(focusNode: _endFocus, child: const Text('To')),
                      Input(
                        controller: _end,
                        focusNode: _endFocus,
                        invalid: _errors.end != null,
                        placeholder: 'hh:mm',
                        semanticLabel: 'To',
                        keyboardType: TextInputType.datetime,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_errors.end != null) _error(_errors.end),
            Field(
              children: [
                const FieldLabel(child: Text('What sort?')),
                Select(
                  value: _kind.name,
                  onChanged: (name) => setState(
                    () => _kind = CalendarPlannerKind.values.byName(name),
                  ),
                  content: SelectContent(
                    children: [
                      for (final kind in CalendarPlannerKind.values)
                        SelectItem(value: kind.name, child: Text(kind.label)),
                    ],
                  ),
                  child: const SelectTrigger(semanticLabel: 'What sort?'),
                ),
              ],
            ),
            Field(
              children: [
                FieldLabel(focusNode: _notesFocus, child: const Text('Notes')),
                Textarea(
                  controller: _notes,
                  focusNode: _notesFocus,
                  semanticLabel: 'Notes',
                ),
              ],
            ),
          ],
        ),
        DialogFooter(
          children: [
            if (event != null)
              Button(
                variant: ButtonVariant.destructive,
                onPressed: () => widget.onDelete(event),
                leading: const InkIcon('trash'),
                child: const Text('Delete'),
              ),
            DialogClose(
              builder: (context, close) => Button(
                variant: ButtonVariant.outline,
                onPressed: close,
                child: const Text('Cancel'),
              ),
            ),
            Button(
              onPressed: _submit,
              child: Text(switch (event) {
                null => 'Add it',
                _ => 'Save changes',
              }),
            ),
          ],
        ),
      ],
    );
  }
}
