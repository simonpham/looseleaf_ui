import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

class CardLoginExample extends StatelessWidget {
  const CardLoginExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            seed: 'login',
            children: [
              CardHeader(
                children: [
                  const CardTitle(Text('Login to your account')),
                  const CardDescription(
                    Text('Enter your email below to login to your account'),
                  ),
                  CardAction(
                    child: Button(
                      variant: ButtonVariant.link,
                      onPressed: () {},
                      child: const Text('Sign up'),
                    ),
                  ),
                ],
              ),
              CardContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d24,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d8,
                      children: [
                        Label(child: Text('Email')),
                        Input(
                          placeholder: 'm@example.com',
                          keyboardType: TextInputType.emailAddress,
                          semanticLabel: 'Email',
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d8,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Label(child: Text('Password')),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Forgot your password?',
                                style: theme.typography.interface(
                                  cssSize: 14,
                                  color: theme.colors.inkYou,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Input(
                          obscureText: true,
                          semanticLabel: 'Password',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CardFooter(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d12,
                children: [
                  Button(onPressed: () {}, child: const Text('Login')),
                  Button(
                    variant: ButtonVariant.outline,
                    onPressed: () {},
                    child: const Text('Login with Google'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
