import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/login_01/login_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A centered sign-in card on the desk, with Stubby peeking over it.
///
/// Mirrors upstream `src/blocks/login-01/page.tsx`.
class Login01Block extends StatelessWidget {
  const Login01Block({super.key});

  static const double _maxWidth = 384;
  static const double _wideFrom = 576;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: switch (constraints.maxWidth >= _wideFrom) {
        true => const EdgeInsets.fromLTRB(
          Spacing.d40,
          Spacing.d96,
          Spacing.d40,
          Spacing.d40,
        ),
        false => const EdgeInsets.fromLTRB(
          Spacing.d24,
          Spacing.d96,
          Spacing.d24,
          Spacing.d24,
        ),
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: const Login01Form(),
        ),
      ),
    ),
  );
}
