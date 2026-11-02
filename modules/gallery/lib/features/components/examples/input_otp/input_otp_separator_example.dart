import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputOtpSeparatorExample extends StatelessWidget {
  const InputOtpSeparatorExample({super.key});

  @override
  Widget build(BuildContext context) => const InputOTP(
    maxLength: 6,
    semanticLabel: 'One-time password',
    children: [
      InputOTPGroup(
        children: [InputOTPSlot(index: 0), InputOTPSlot(index: 1)],
      ),
      InputOTPSeparator(),
      InputOTPGroup(
        children: [InputOTPSlot(index: 2), InputOTPSlot(index: 3)],
      ),
      InputOTPSeparator(),
      InputOTPGroup(
        children: [InputOTPSlot(index: 4), InputOTPSlot(index: 5)],
      ),
    ],
  );
}
