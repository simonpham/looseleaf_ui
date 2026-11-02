import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputOtpLettersAndInvalidExample extends StatefulWidget {
  const InputOtpLettersAndInvalidExample({super.key});

  @override
  State<InputOtpLettersAndInvalidExample> createState() =>
      _InputOtpLettersAndInvalidExampleState();
}

class _InputOtpLettersAndInvalidExampleState
    extends State<InputOtpLettersAndInvalidExample> {
  static const _right = 'AB12';

  final _code = TextEditingController(text: 'AB13');
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _code.addListener(_upperCase);
  }

  void _upperCase() {
    final upper = _code.text.toUpperCase();
    if (upper != _code.text) {
      _code.value = _code.value.copyWith(text: upper);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final value = _code.text;
    final wrong = value.length == 4 && value != _right;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        Label(focusNode: _focus, child: const Text('Invite code')),
        InputOTP(
          maxLength: 4,
          controller: _code,
          focusNode: _focus,
          pattern: InputOTPPattern.digitsAndChars,
          invalid: wrong,
          semanticLabel: 'Invite code',
          children: const [
            InputOTPGroup(
              children: [
                InputOTPSlot(index: 0),
                InputOTPSlot(index: 1),
                InputOTPSlot(index: 2),
                InputOTPSlot(index: 3),
              ],
            ),
          ],
        ),
        Semantics(
          liveRegion: wrong,
          child: Text(
            switch ((wrong, value == _right)) {
              (true, _) => 'That code does not match. Try again.',
              (_, true) => 'That is the one.',
              _ => 'Four letters or digits.',
            },
            style: theme.typography.interface(
              cssSize: 14,
              color: switch (wrong) {
                true => theme.colors.red,
                false => theme.colors.inkMuted,
              },
            ),
          ),
        ),
      ],
    );
  }
}
