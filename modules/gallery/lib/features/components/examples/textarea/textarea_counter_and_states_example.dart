import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaCounterAndStatesExample extends StatefulWidget {
  const TextareaCounterAndStatesExample({super.key});

  @override
  State<TextareaCounterAndStatesExample> createState() =>
      _TextareaCounterAndStatesExampleState();
}

class _TextareaCounterAndStatesExampleState
    extends State<TextareaCounterAndStatesExample> {
  final _locked = TextEditingController(text: 'Nothing to add.');
  final _printed = TextEditingController(
    text: 'Printed in the margin: this one cannot be edited, only selected.',
  );
  int _bioLength = 0;

  @override
  void dispose() {
    _locked.dispose();
    _printed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final short = _bioLength > 0 && _bioLength < 20;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d20,
        children: [
          Textarea(
            semanticLabel: 'Bio',
            placeholder: 'A few words about you (20 or more)',
            maxLength: 140,
            showCount: true,
            invalid: short,
            onChanged: (bio) => setState(() => _bioLength = bio.length),
          ),
          Textarea(
            controller: _locked,
            semanticLabel: 'Locked',
            disabled: true,
          ),
          Textarea(
            controller: _printed,
            semanticLabel: 'Read only',
            readOnly: true,
          ),
        ],
      ),
    );
  }
}
