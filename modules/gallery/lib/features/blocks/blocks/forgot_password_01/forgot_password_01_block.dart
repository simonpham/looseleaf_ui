import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/forgot_password_01/forgot_password_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A taped card on the desk that asks for an email and sends a reset link,
/// with Stubby searching for the lost password.
///
/// Mirrors upstream `src/blocks/forgot-password-01/page.tsx`.
class ForgotPassword01Block extends StatelessWidget {
  const ForgotPassword01Block({super.key});

  static const double _maxWidth = 384;
  static const double _wideFrom = 576;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: EdgeInsets.all(switch (constraints.maxWidth >= _wideFrom) {
        true => Spacing.d40,
        false => Spacing.d24,
      }),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: const ForgotPassword01Form(),
        ),
      ),
    ),
  );
}
