import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputOtpPatternExample extends StatelessWidget {
  const InputOtpPatternExample({super.key});

  @override
  Widget build(BuildContext context) => const InputOTP(
    maxLength: 6,
    pattern: InputOTPPattern.digitsAndChars,
    semanticLabel: 'Code',
    children: [
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
  );
}
