import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The card once the code checks out: a green rosette and a way on.
class Otp01Verified extends StatelessWidget {
  const Otp01Verified({
    super.key,
    required this.email,
    required this.titleFocus,
    this.onContinue,
  });

  /// The confirmed address.
  final String email;

  /// Takes focus when the card shows.
  final FocusNode titleFocus;

  /// Called by the Continue button.
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Card(
      tape: PaperTape.corner,
      seed: 'otp-01-done',
      children: [
        CardHeader(
          children: [
            const Center(
              child: Seal(
                variant: SealVariant.rosette,
                mark: SealMark.check,
                tone: PaintKey.grass,
                size: 104,
                semanticLabel: 'Verified',
                tilt: -4,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Focus(
                focusNode: titleFocus,
                child: CardTitle(
                  Text(
                    'You are verified',
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
            ),
            SizedBox(
              width: double.infinity,
              child: CardDescription(
                Text(
                  '$email is confirmed. Welcome to the desk.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        CardContent(
          child: Button(
            onPressed: onContinue ?? () {},
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
