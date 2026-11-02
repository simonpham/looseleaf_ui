import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

/// `min-h-[72px]`.
const _signatureHeight = 72.0;

class SignatureLetterExample extends StatefulWidget {
  const SignatureLetterExample({super.key});

  @override
  State<SignatureLetterExample> createState() => _SignatureLetterExampleState();
}

class _SignatureLetterExampleState extends State<SignatureLetterExample> {
  bool _signed = true;
  Timer? _timer;

  void _signAgain() {
    setState(() => _signed = false);
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 60),
      () => setState(() => _signed = true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Paper(
            rules: RuleName.ruled,
            seed: 'letter',
            padding: const EdgeInsets.fromLTRB(
              Spacing.d56,
              Spacing.d16,
              Spacing.d24,
              Spacing.d24,
            ),
            child: DefaultTextStyle.merge(
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 15,
                cssLineHeight: 28 / 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thank you for the tomatoes, the jam, and the long '
                    'letter; I read it twice. Come and see the garden in June.',
                  ),
                  const Text('Yours, always,'),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: _signatureHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: Spacing.d14),
                      child: switch (_signed) {
                        true => const Signature(
                          animate: true,
                          child: Text('Sam Whitcombe'),
                        ),
                        false => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: _signAgain,
              child: const Text('Sign again'),
            ),
          ),
        ],
      ),
    );
  }
}
