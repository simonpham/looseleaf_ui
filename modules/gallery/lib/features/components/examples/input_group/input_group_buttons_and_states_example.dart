import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupButtonsAndStatesExample extends StatefulWidget {
  const InputGroupButtonsAndStatesExample({super.key});

  @override
  State<InputGroupButtonsAndStatesExample> createState() =>
      _InputGroupButtonsAndStatesExampleState();
}

class _InputGroupButtonsAndStatesExampleState
    extends State<InputGroupButtonsAndStatesExample> {
  final _link = TextEditingController(
    text: 'https://looseleaf.dev/r/field-notes',
  );
  final _email = TextEditingController(text: 'not-an-email');
  final _locked = TextEditingController(text: 'locked by your admin');
  bool _copied = false;

  @override
  void dispose() {
    _link.dispose();
    _email.dispose();
    _locked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 384),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        InputGroup(
          children: [
            InputGroupInput(
              controller: _link,
              readOnly: true,
              semanticLabel: 'Share link',
            ),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: InputGroupButton(
                size: InputGroupButtonSize.iconXs,
                semanticLabel: 'Copy link',
                onPressed: () => setState(() => _copied = true),
                child: InkIcon(switch (_copied) {
                  true => 'check',
                  false => 'copy',
                }),
              ),
            ),
          ],
        ),
        InputGroup(
          invalid: true,
          children: [
            const InputGroupAddon(child: InkIcon('mail')),
            InputGroupInput(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              semanticLabel: 'Email',
            ),
          ],
        ),
        InputGroup(
          disabled: true,
          children: [
            const InputGroupAddon(child: InkIcon('lock')),
            InputGroupInput(controller: _locked, semanticLabel: 'Locked'),
          ],
        ),
        const InputGroup(
          disabled: true,
          children: [
            InputGroupInput(
              placeholder: 'A group can be disabled as a whole',
              semanticLabel: 'Disabled group',
            ),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: InputGroupButton(
                disabled: true,
                variant: ButtonVariant.secondary,
                child: Text('Send'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
