import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/forgot_password_01/forgot_password_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The card after the link went out: an envelope sticker, where it went,
/// a way back to sign in and a link to send it again.
class ForgotPassword01Sent extends StatelessWidget {
  const ForgotPassword01Sent({
    super.key,
    required this.sentTo,
    required this.titleFocus,
    this.demo = true,
    this.formError,
    this.resending = false,
    this.sentAgain = false,
    this.onSendAgain,
  });

  /// The address the link went to.
  final String sentTo;

  /// Takes focus when the card shows.
  final FocusNode titleFocus;

  /// Adds the demo note.
  final bool demo;

  /// Why sending again failed.
  final String? formError;

  /// Whether the link is being sent again.
  final bool resending;

  /// Whether the last send-again went through.
  final bool sentAgain;

  /// Sends the link again.
  final VoidCallback? onSendAgain;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Card(
      tape: PaperTape.corner,
      seed: 'forgot-password-01-sent',
      children: [
        CardHeader(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Sticker('envelope-heart', size: 96, rotate: -6),
            Focus(
              focusNode: titleFocus,
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
            CardDescription(
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    const TextSpan(text: 'If '),
                    TextSpan(
                      text: sentTo,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' has an account, a link to choose a new password is on its way. It works for one hour.${switch (demo) {
                            true => ' (This is a demo: nothing was sent.)',
                            false => '',
                          }}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        CardContent(
          child: FieldGroup(
            children: [
              if (formError case final message?)
                Alert(
                  variant: AlertTone.destructive,
                  icon: const InkIcon('circle-alert'),
                  children: [
                    const AlertTitle(Text('That did not go through')),
                    AlertDescription(Text(message)),
                  ],
                ),
              Field(
                children: [
                  Button(
                    onPressed: () {},
                    child: const Text('Back to sign in'),
                  ),
                  FieldDescription(
                    Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Nothing yet? Look in your spam folder, or ',
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: ForgotPassword01Link(
                              'send it again',
                              disabled: resending,
                              onPressed: onSendAgain,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                  Semantics(
                    liveRegion: true,
                    label: switch (sentAgain) {
                      true => 'We sent the link again.',
                      false => '',
                    },
                    child: const SizedBox.shrink(),
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
