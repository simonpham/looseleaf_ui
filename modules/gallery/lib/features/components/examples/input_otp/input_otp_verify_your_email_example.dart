import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _Check { idle, wrong, done }

class InputOtpVerifyYourEmailExample extends StatefulWidget {
  const InputOtpVerifyYourEmailExample({super.key});

  @override
  State<InputOtpVerifyYourEmailExample> createState() =>
      _InputOtpVerifyYourEmailExampleState();
}

class _InputOtpVerifyYourEmailExampleState
    extends State<InputOtpVerifyYourEmailExample> {
  static const _right = '246810';

  final _code = TextEditingController();
  _Check _check = _Check.idle;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _verify(String code) => setState(
    () => _check = switch (code == _right) {
      true => _Check.done,
      false => _Check.wrong,
    },
  );

  void _startOver() {
    _code.clear();
    setState(() => _check = _Check.idle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Card(
        seed: 'verify',
        tape: PaperTape.corner,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Check your email')),
              CardDescription(
                Text('We sent a six-digit code to ada@analytical.engine.'),
              ),
            ],
          ),
          CardContent(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
              child: Column(
                spacing: Spacing.d12,
                children: [
                  InputOTP(
                    maxLength: 6,
                    controller: _code,
                    disabled: _check == _Check.done,
                    invalid: _check == _Check.wrong,
                    semanticLabel: 'Verification code',
                    onChanged: (_) => setState(() {
                      if (_check == _Check.wrong) _check = _Check.idle;
                    }),
                    onComplete: _verify,
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
                      switch (_check) {
                        _Check.done => 'Verified. Welcome to the notebook.',
                        _Check.wrong =>
                          'That is not the code. Check the email and try again.',
                        _Check.idle => 'It expires in ten minutes.',
                      },
                      textAlign: TextAlign.center,
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: switch (_check) {
                          _Check.wrong => theme.colors.red,
                          _ => theme.colors.inkMuted,
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CardFooter(
            divider: true,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: Spacing.d12,
            children: [
              Flexible(
                child: Button(
                  variant: ButtonVariant.link,
                  size: ButtonSize.sm,
                  onPressed: _startOver,
                  child: Text(
                    switch (_check) {
                      _Check.wrong => 'Start over',
                      _ => 'Send it again',
                    },
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Button(
                disabled: _code.text.length < 6 || _check == _Check.done,
                onPressed: () => _verify(_code.text),
                child: const Text('Verify'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
