import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/otp_01/otp_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The code the demo accepts.
const otp01DemoCode = '246810';

enum _Status { idle, verifying, wrong, verified }

/// A six-digit code in two groups of three, checked as soon as it is
/// whole, with a resend countdown.
///
/// Mirrors upstream `src/blocks/otp-01/components/otp-01-form.tsx`.
class Otp01Form extends StatefulWidget {
  const Otp01Form({
    super.key,
    this.email = 'ada@notes.dev',
    this.onVerify,
    this.onResend,
    this.onContinue,
    this.resendAfter = 30,
  });

  /// Where the code went.
  final String email;

  /// Checks a code; the demo accepts [otp01DemoCode].
  final Future<bool> Function(String code)? onVerify;

  /// Sends a new code.
  final Future<void> Function()? onResend;

  /// Called by the Continue button once verified.
  final VoidCallback? onContinue;

  /// Seconds before a new code can be asked for.
  final int resendAfter;

  @override
  State<Otp01Form> createState() => _Otp01FormState();
}

class _Otp01FormState extends State<Otp01Form> {
  static const _wrongCode =
      'That code is not right. Check the latest email and try again.';

  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  final _titleFocus = FocusNode();
  Timer? _timer;
  _Status _status = _Status.idle;
  String _message = _wrongCode;
  late int _left = widget.resendAfter;
  bool _resent = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _codeFocus.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_left <= 1) timer.cancel();
      setState(() => _left -= 1);
    });
  }

  static Future<bool> _demoVerify(String code) => Future<bool>.delayed(
    const Duration(milliseconds: 600),
    () => code == otp01DemoCode,
  );

  void _wrong(String message) {
    _code.clear();
    setState(() {
      _message = message;
      _status = _Status.wrong;
    });
    _codeFocus.requestFocus();
  }

  Future<void> _verify(String value) async {
    if (_busy || value.length < 6) return;
    _busy = true;
    setState(() => _status = _Status.verifying);
    try {
      final ok = await (widget.onVerify ?? _demoVerify)(value);
      if (!mounted) return;
      if (!ok) {
        _wrong(_wrongCode);
        return;
      }
      setState(() => _status = _Status.verified);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _titleFocus.requestFocus(),
      );
    } on Object {
      if (!mounted) return;
      _wrong('We could not check that code. Try again in a moment.');
    } finally {
      _busy = false;
    }
  }

  Future<void> _resend() async {
    _code.clear();
    setState(() {
      _resent = true;
      _status = _Status.idle;
      _left = widget.resendAfter;
    });
    _startCountdown();
    _codeFocus.requestFocus();
    try {
      await widget.onResend?.call();
    } on Object {
      if (!mounted) return;
      setState(() => _resent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == _Status.verified) {
      return Otp01Verified(
        email: widget.email,
        titleFocus: _titleFocus,
        onContinue: widget.onContinue,
      );
    }
    final theme = LooseleafTheme.of(context);
    final verifying = _status == _Status.verifying;
    final wrong = _status == _Status.wrong;
    return Card(
      tape: PaperTape.corner,
      seed: 'otp-01',
      children: [
        CardHeader(
          children: [
            Center(
              child: Mascot(
                pose: switch (_status) {
                  _Status.wrong => 'oops',
                  _Status.verifying => 'search',
                  _ => 'think',
                },
                size: 80,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CardTitle(
                Text(
                  'Check your email',
                  textAlign: TextAlign.center,
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 32,
                    cssLineHeight: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: CardDescription(
                Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      const TextSpan(text: 'We sent a six-digit code to '),
                      TextSpan(
                        text: widget.email,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colors.ink,
                        ),
                      ),
                      const TextSpan(text: '. It works for ten minutes.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        CardContent(
          child: FieldGroup(
            children: [
              Field(
                invalid: wrong,
                children: [
                  Center(
                    child: InputOTP(
                      maxLength: 6,
                      controller: _code,
                      focusNode: _codeFocus,
                      pattern: InputOTPPattern.digits,
                      disabled: verifying,
                      invalid: wrong,
                      semanticLabel: 'Verification code',
                      onChanged: (_) => setState(() {
                        if (wrong) _status = _Status.idle;
                      }),
                      onComplete: (value) => unawaited(_verify(value)),
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
                  ),
                  switch (wrong) {
                    true => SizedBox(
                      width: double.infinity,
                      child: FieldError(
                        child: Text(_message, textAlign: TextAlign.center),
                      ),
                    ),
                    false => const SizedBox(
                      width: double.infinity,
                      child: FieldDescription(
                        Text(
                          'Type it, or paste it whole.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  },
                ],
              ),
              Field(
                children: [
                  Button(
                    disabled: verifying || _code.text.length < 6,
                    onPressed: () => unawaited(_verify(_code.text)),
                    leading: switch (verifying) {
                      true => const ExcludeSemantics(child: Spinner()),
                      false => null,
                    },
                    child: Text(switch (verifying) {
                      true => 'Checking',
                      false => 'Verify',
                    }),
                  ),
                  FieldDescription(
                    switch (_left > 0) {
                      true => Semantics(
                        liveRegion: _resent,
                        child: Text(
                          'Need another? You can ask again in ${_left}s.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      false => Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Did not get it? '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: Otp01Link(
                                'Resend code',
                                onPressed: () => unawaited(_resend()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                  ),
                  const FieldDescription(
                    Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          TextSpan(text: 'Wrong address? '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Otp01Link('Change your email'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
