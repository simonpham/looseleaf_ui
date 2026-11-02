import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputOtpControlledExample extends StatefulWidget {
  const InputOtpControlledExample({super.key});

  @override
  State<InputOtpControlledExample> createState() =>
      _InputOtpControlledExampleState();
}

class _InputOtpControlledExampleState extends State<InputOtpControlledExample> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d8,
      children: [
        InputOTP(
          maxLength: 6,
          semanticLabel: 'One-time password',
          onChanged: (value) => setState(() => _value = value),
          children: const [
            InputOTPGroup(
              children: [
                InputOTPSlot(index: 0),
                InputOTPSlot(index: 1),
                InputOTPSlot(index: 2),
                InputOTPSlot(index: 3),
                InputOTPSlot(index: 4),
                InputOTPSlot(index: 5),
              ],
            ),
          ],
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            switch (_value) {
              '' => 'Enter your one-time password.',
              final code => 'You entered: $code',
            },
            style: theme.typography.interface(cssSize: 14),
          ),
        ),
      ],
    );
  }
}
