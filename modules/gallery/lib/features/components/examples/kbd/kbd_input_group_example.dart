import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-xs`.
const _maxWidth = Spacing.d320;

class KbdInputGroupExample extends StatelessWidget {
  const KbdInputGroupExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const InputGroup(
      children: [
        InputGroupInput(placeholder: 'Search...', semanticLabel: 'Search'),
        InputGroupAddon(child: InkIcon('search')),
        InputGroupAddon(
          align: InputGroupAlign.inlineEnd,
          child: KbdGroup(
            children: [
              Kbd(child: Text('⌘')),
              Kbd(child: Text('K')),
            ],
          ),
        ),
      ],
    ),
  );
}
