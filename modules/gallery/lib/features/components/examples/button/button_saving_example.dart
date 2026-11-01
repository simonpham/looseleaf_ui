import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _Phase { idle, saving, saved }

class ButtonSavingExample extends StatefulWidget {
  const ButtonSavingExample({super.key});

  @override
  State<ButtonSavingExample> createState() => _ButtonSavingExampleState();
}

class _ButtonSavingExampleState extends State<ButtonSavingExample> {
  _Phase _phase = _Phase.idle;
  Timer? _timer;

  void _save() {
    setState(() => _phase = _Phase.saving);
    _timer = Timer(const Duration(milliseconds: 1400), () {
      setState(() => _phase = _Phase.saved);
      _timer = Timer(
        const Duration(milliseconds: 1600),
        () => setState(() => _phase = _Phase.idle),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final saving = _phase == _Phase.saving;
    return Wrap(
      spacing: Spacing.d16,
      runSpacing: Spacing.d16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button(
          onPressed: _save,
          disabled: saving,
          variant: switch (_phase) {
            _Phase.saved => ButtonVariant.secondary,
            _ => ButtonVariant.primary,
          },
          forcedStates: {if (saving) InkState.busy},
          child: Text(switch (_phase) {
            _Phase.idle => 'Save changes',
            _Phase.saving => 'Saving...',
            _Phase.saved => 'Saved, thanks',
          }),
        ),
        Button(
          variant: ButtonVariant.ghost,
          disabled: _phase != _Phase.idle,
          onPressed: () {},
          child: const Text('Cancel'),
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            switch (_phase) {
              _Phase.idle => '',
              _Phase.saving => 'Writing it down...',
              _Phase.saved => 'All changes kept.',
            },
            style: TextStyle(color: theme.colors.inkMuted),
          ),
        ),
      ],
    );
  }
}
