import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputOtpSixDigitsExample extends StatefulWidget {
  const InputOtpSixDigitsExample({super.key});

  @override
  State<InputOtpSixDigitsExample> createState() =>
      _InputOtpSixDigitsExampleState();
}

class _InputOtpSixDigitsExampleState extends State<InputOtpSixDigitsExample> {
  final _code = TextEditingController(text: '482');
  final _focus = FocusNode();

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        Label(focusNode: _focus, child: const Text('One-time code')),
        InputOTP(
          maxLength: 6,
          controller: _code,
          focusNode: _focus,
          semanticLabel: 'One-time code',
          onChanged: (_) => setState(() {}),
          children: const [
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
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            switch (_code.text) {
              '' => 'Enter your one-time password.',
              final code => 'You entered: $code',
            },
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
