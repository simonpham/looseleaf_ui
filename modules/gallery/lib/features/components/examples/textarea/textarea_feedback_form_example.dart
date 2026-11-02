import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaFeedbackFormExample extends StatefulWidget {
  const TextareaFeedbackFormExample({super.key});

  @override
  State<TextareaFeedbackFormExample> createState() =>
      _TextareaFeedbackFormExampleState();
}

class _TextareaFeedbackFormExampleState
    extends State<TextareaFeedbackFormExample> {
  final _subjectFocus = FocusNode();
  final _noteFocus = FocusNode();
  String _note = '';
  bool _missing = false;
  bool _sent = false;

  @override
  void dispose() {
    _subjectFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _send() {
    if (_note.trim().isEmpty) {
      setState(() => _missing = true);
      _noteFocus.requestFocus();
      return;
    }
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d20,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d8,
          children: [
            Label(focusNode: _subjectFocus, child: const Text('Subject')),
            Input(focusNode: _subjectFocus, placeholder: 'The short version'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d8,
          children: [
            Label(
              focusNode: _noteFocus,
              required: true,
              child: const Text('Your note'),
            ),
            Textarea(
              focusNode: _noteFocus,
              ruled: true,
              showCount: true,
              maxLength: 400,
              invalid: _missing,
              placeholder: 'What should we know?',
              onChanged: (note) => setState(() {
                _note = note;
                _missing = false;
              }),
            ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Button(
            disabled: _sent,
            onPressed: _send,
            child: Text(switch (_sent) {
              true => 'Sent, thank you',
              false => 'Send feedback',
            }),
          ),
        ),
      ],
    ),
  );
}
