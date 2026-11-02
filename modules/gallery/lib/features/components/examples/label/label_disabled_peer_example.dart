import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LabelDisabledPeerExample extends StatefulWidget {
  const LabelDisabledPeerExample({super.key});

  @override
  State<LabelDisabledPeerExample> createState() =>
      _LabelDisabledPeerExampleState();
}

class _LabelDisabledPeerExampleState extends State<LabelDisabledPeerExample> {
  final _email = TextEditingController(text: 'locked@example.com');

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d384),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d20,
      children: [
        const Row(
          spacing: Spacing.d8,
          children: [
            Checkbox(value: false, disabled: true),
            Flexible(
              child: Label(
                disabled: true,
                child: Text('Sync over cellular (off by admin)'),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d8,
          children: [
            const Label(disabled: true, child: Text('Account email')),
            Input(controller: _email, disabled: true),
          ],
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d8,
          children: [
            Label(disabled: true, child: Text('Whole group is disabled')),
            Input(
              semanticLabel: 'grouped',
              disabled: true,
              placeholder: 'Nothing to type here',
            ),
          ],
        ),
      ],
    ),
  );
}
