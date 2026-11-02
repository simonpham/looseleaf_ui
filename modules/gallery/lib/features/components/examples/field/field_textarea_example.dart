import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldTextareaExample extends StatefulWidget {
  const FieldTextareaExample({super.key});

  @override
  State<FieldTextareaExample> createState() => _FieldTextareaExampleState();
}

class _FieldTextareaExampleState extends State<FieldTextareaExample> {
  static const _maxWidth = Spacing.d448;

  final _feedback = FocusNode();

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldSet(
      children: [
        FieldGroup(
          children: [
            Field(
              children: [
                FieldLabel(focusNode: _feedback, child: const Text('Feedback')),
                Textarea(
                  focusNode: _feedback,
                  placeholder: 'Your feedback helps us improve...',
                  rows: 4,
                ),
                const FieldDescription(
                  Text('Share your thoughts about our service.'),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
