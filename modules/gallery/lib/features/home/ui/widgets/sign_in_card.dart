import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The hero's sign-in card: a working form on taped paper that says
/// "Signed in" for a moment when sent. Nothing is sent anywhere.
///
/// Mirrors upstream `src/docs/content/home/sign-in.tsx`.
class SignInCard extends StatefulWidget {
  const SignInCard({super.key});

  @override
  State<SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends State<SignInCard> {
  static const Duration _signedInFor = Duration(milliseconds: 2400);

  final TextEditingController _email = TextEditingController(
    text: 'ada@looseleaf.dev',
  );
  final TextEditingController _password = TextEditingController(
    text: 'pencil-case',
  );
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _remember = true;
  bool _signedIn = false;
  Timer? _timer;

  void _submit() {
    _timer?.cancel();
    setState(() => _signedIn = true);
    _timer = Timer(_signedInFor, () => setState(() => _signedIn = false));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Card(
        stock: StockName.paper,
        tape: PaperTape.both,
        seed: 'home-sign-in',
        gap: Spacing.d20,
        padding: const EdgeInsets.symmetric(vertical: Spacing.d28),
        children: [
          CardHeader(
            children: [
              CardTitle(
                Text(
                  'Welcome back',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 36,
                    cssLineHeight: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const CardDescription(
                Text('sign in to pick up where you left off.'),
              ),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d8,
                  children: [
                    Label(focusNode: _emailFocus, child: const Text('Email')),
                    Input(
                      controller: _email,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      seed: 'home-email',
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d8,
                  children: [
                    Row(
                      spacing: Spacing.d12,
                      children: [
                        Expanded(
                          child: Label(
                            focusNode: _passwordFocus,
                            child: const Text('Password'),
                          ),
                        ),
                        Button(
                          variant: ButtonVariant.link,
                          size: ButtonSize.xs,
                          onPressed: () {},
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    Input(
                      controller: _password,
                      focusNode: _passwordFocus,
                      obscureText: true,
                      onSubmitted: (_) => _submit(),
                      seed: 'home-password',
                    ),
                  ],
                ),
                Checkbox(
                  value: _remember,
                  onChanged: (remember) => setState(() => _remember = remember),
                  label: const Text('Remember me on this desk'),
                ),
              ],
            ),
          ),
          CardFooter(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [
              Button(
                size: ButtonSize.lg,
                onPressed: _submit,
                leading: switch (_signedIn) {
                  true => const InkIcon('check'),
                  false => null,
                },
                semanticLabel: switch (_signedIn) {
                  true =>
                    'Signed in as ada@looseleaf.dev (a demo: nothing was sent)',
                  false => null,
                },
                child: Text(switch (_signedIn) {
                  true => 'Signed in',
                  false => 'Sign in',
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: Spacing.d4,
                children: [
                  Text(
                    'New here?',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                  Button(
                    variant: ButtonVariant.link,
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Make an account'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
