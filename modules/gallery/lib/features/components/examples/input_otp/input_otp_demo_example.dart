import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputOtpDemoExample extends StatelessWidget {
  const InputOtpDemoExample({super.key});

  @override
  Widget build(BuildContext context) => const InputOTP(
    maxLength: 6,
    semanticLabel: 'One-time password',
    children: [
      InputOTPGroup(
        children: [
          InputOTPSlot(index: 0),
          InputOTPSlot(index: 1),
          InputOTPSlot(index: 2),
        ],
      ),
      InputOTPSeparator(),
      InputOTPGroup(
        children: [
          InputOTPSlot(index: 3),
          InputOTPSlot(index: 4),
          InputOTPSlot(index: 5),
        ],
      ),
    ],
  );
}
