import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonLoadingSpinnerExample extends StatefulWidget {
  const ButtonLoadingSpinnerExample({super.key});

  @override
  State<ButtonLoadingSpinnerExample> createState() =>
      _ButtonLoadingSpinnerExampleState();
}

class _ButtonLoadingSpinnerExampleState
    extends State<ButtonLoadingSpinnerExample> {
  bool _sending = false;
  Timer? _timer;

  void _send() {
    if (_sending) return;
    setState(() => _sending = true);
    _timer = Timer(
      const Duration(milliseconds: 2200),
      () => setState(() => _sending = false),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      const Button(
        size: ButtonSize.sm,
        variant: ButtonVariant.outline,
        disabled: true,
        leading: Spinner(),
        child: Text('Submit'),
      ),
      Button(
        onPressed: _send,
        forcedStates: {if (_sending) InkState.busy},
        leading: switch (_sending) {
          true => const Spinner(),
          false => null,
        },
        child: Text(switch (_sending) {
          true => 'Sending',
          false => 'Send the letter',
        }),
      ),
      const Button(
        variant: ButtonVariant.secondary,
        disabled: true,
        leading: Spinner(),
        child: Text('Please wait'),
      ),
    ],
  );
}
