import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _keys = [
  (label: 'Esc', key: PhysicalKeyboardKey.escape),
  (label: 'Tab', key: PhysicalKeyboardKey.tab),
  (label: 'Space', key: PhysicalKeyboardKey.space),
  (label: 'Enter', key: PhysicalKeyboardKey.enter),
  (label: '←', key: PhysicalKeyboardKey.arrowLeft),
  (label: '↑', key: PhysicalKeyboardKey.arrowUp),
  (label: '↓', key: PhysicalKeyboardKey.arrowDown),
  (label: '→', key: PhysicalKeyboardKey.arrowRight),
];

class KbdPressTheKeysExample extends StatefulWidget {
  const KbdPressTheKeysExample({super.key});

  @override
  State<KbdPressTheKeysExample> createState() => _KbdPressTheKeysExampleState();
}

class _KbdPressTheKeysExampleState extends State<KbdPressTheKeysExample> {
  final Set<PhysicalKeyboardKey> _down = {};

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (!_keys.any((entry) => entry.key == event.physicalKey)) return false;
    setState(() {
      if (event is KeyUpEvent) {
        _down.remove(event.physicalKey);
        return;
      }
      _down.add(event.physicalKey);
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        Semantics(
          label: 'Keys you are holding',
          container: true,
          child: Wrap(
            spacing: Spacing.d8,
            runSpacing: Spacing.d8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final entry in _keys)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: Spacing.d36),
                  child: Kbd(
                    pressed: _down.contains(entry.key),
                    child: Text(entry.label),
                  ),
                ),
            ],
          ),
        ),
        Text(
          'Try Space, Enter, Esc and the arrow keys.',
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.inkMuted,
          ),
        ),
      ],
    );
  }
}
