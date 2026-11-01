import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class KbdModifiersExample extends StatelessWidget {
  const KbdModifiersExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d16,
    children: [
      KbdGroup(
        children: [
          Kbd(child: Text('⌘')),
          Kbd(child: Text('⇧')),
          Kbd(child: Text('⌥')),
          Kbd(child: Text('⌃')),
        ],
      ),
      KbdGroup(
        children: [
          Kbd(child: Text('Ctrl')),
          Text('+'),
          Kbd(child: Text('B')),
        ],
      ),
    ],
  );
}
