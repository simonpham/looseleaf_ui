import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalloutOnboardingExample extends StatefulWidget {
  const CalloutOnboardingExample({super.key});

  @override
  State<CalloutOnboardingExample> createState() =>
      _CalloutOnboardingExampleState();
}

class _CalloutOnboardingExampleState extends State<CalloutOnboardingExample> {
  static const _maxWidth = 320.0;

  final _email = FocusNode();
  bool _hint = true;

  @override
  void initState() {
    super.initState();
    _email.addListener(_onFocus);
  }

  void _onFocus() {
    if (!_email.hasFocus) return;
    setState(() => _hint = false);
  }

  @override
  void dispose() {
    _email
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.d48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d8,
                children: [
                  Label(focusNode: _email, child: const Text('Email')),
                  Input(
                    focusNode: _email,
                    keyboardType: TextInputType.emailAddress,
                    placeholder: 'you@example.com',
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              start: Spacing.d32,
              bottom: 0,
              child: IgnorePointer(
                child: Callout(
                  'start with this one',
                  show: _hint,
                  animate: true,
                  direction: ArrowDirection.upRight,
                ),
              ),
            ),
          ],
        ),
        Button(onPressed: () {}, child: const Text('Send the link')),
      ],
    ),
  );
}
