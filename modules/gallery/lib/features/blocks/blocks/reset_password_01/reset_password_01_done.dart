import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The card after saving: a green "done" rosette and a way back to sign in.
class ResetPassword01Done extends StatelessWidget {
  const ResetPassword01Done({
    super.key,
    required this.titleFocus,
    this.demo = true,
  });

  /// Takes focus when the card shows.
  final FocusNode titleFocus;

  /// Adds the demo note.
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Card(
      tape: PaperTape.corner,
      seed: 'reset-password-01-done',
      children: [
        CardHeader(
          children: [
            const Center(
              child: Seal(
                variant: SealVariant.rosette,
                mark: SealMark.check,
                tone: PaintKey.grass,
                size: 104,
                semanticLabel: 'Done',
                tilt: -4,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Focus(
                focusNode: titleFocus,
                child: CardTitle(
                  Text(
                    'Password changed',
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
                  'You can sign in with it now.${switch (demo) {
                    true => ' (This is a demo: nothing was saved.)',
                    false => '',
                  }}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        CardContent(
          child: Button(onPressed: () {}, child: const Text('Back to sign in')),
        ),
      ],
    );
  }
}
