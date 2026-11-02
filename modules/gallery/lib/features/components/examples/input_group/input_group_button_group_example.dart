import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupButtonGroupExample extends StatefulWidget {
  const InputGroupButtonGroupExample({super.key});

  @override
  State<InputGroupButtonGroupExample> createState() =>
      _InputGroupButtonGroupExampleState();
}

class _InputGroupButtonGroupExampleState
    extends State<InputGroupButtonGroupExample> {
  final _url = FocusNode();

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d384),
    child: ButtonGroup(
      children: [
        ButtonGroupText(
          child: Label(focusNode: _url, child: const Text('https://')),
        ),
        Expanded(
          child: InputGroup(
            focusNode: _url,
            children: const [
              InputGroupInput(semanticLabel: 'URL'),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: InkIcon('link'),
              ),
            ],
          ),
        ),
        const ButtonGroupText(child: Text('.com')),
      ],
    ),
  );
}
