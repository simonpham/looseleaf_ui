import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupCustomExample extends StatelessWidget {
  const InputGroupCustomExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 384),
    child: InputGroup(
      children: [
        const InputGroupTextarea(
          placeholder: 'Autoresize textarea...',
          semanticLabel: 'Autoresize textarea',
          minLines: 2,
        ),
        InputGroupAddon(
          align: InputGroupAlign.blockEnd,
          child: Row(
            children: [
              const Spacer(),
              InputGroupButton(
                size: InputGroupButtonSize.sm,
                variant: ButtonVariant.primary,
                onPressed: () {},
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
