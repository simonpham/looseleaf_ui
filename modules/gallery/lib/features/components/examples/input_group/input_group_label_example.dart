import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupLabelExample extends StatefulWidget {
  const InputGroupLabelExample({super.key});

  @override
  State<InputGroupLabelExample> createState() => _InputGroupLabelExampleState();
}

class _InputGroupLabelExampleState extends State<InputGroupLabelExample> {
  final _handle = FocusNode();
  final _email = FocusNode();

  @override
  void dispose() {
    _handle.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TooltipProvider(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          InputGroup(
            focusNode: _handle,
            children: [
              const InputGroupInput(placeholder: 'shadcn', semanticLabel: '@'),
              InputGroupAddon(
                child: Label(focusNode: _handle, child: const Text('@')),
              ),
            ],
          ),
          InputGroup(
            focusNode: _email,
            children: [
              const InputGroupInput(
                placeholder: 'ada@looseleaf.example',
                semanticLabel: 'Email',
              ),
              InputGroupAddon(
                align: InputGroupAlign.blockStart,
                child: Row(
                  children: [
                    Label(focusNode: _email, child: const Text('Email')),
                    const Spacer(),
                    const Tooltip(
                      content: TooltipContent(
                        child: Text("We'll use this to send you notifications"),
                      ),
                      child: InputGroupButton(
                        size: InputGroupButtonSize.iconXs,
                        semanticLabel: 'Help',
                        child: InkIcon('info'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
