import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputSearchWithIconExample extends StatelessWidget {
  const InputSearchWithIconExample({super.key});

  static const _maxWidth = 384.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const InputGroup(
      children: [
        InputGroupAddon(child: InkIcon('search')),
        InputGroupInput(
          placeholder: 'Search the notebook',
          semanticLabel: 'Search the notebook',
        ),
      ],
    ),
  );
}
