import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/reset_password_01/reset_password_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A taped card on the desk for choosing a new password, with Stubby
/// writing it down and a checklist that ticks as you type.
///
/// Mirrors upstream `src/blocks/reset-password-01/page.tsx`.
class ResetPassword01Block extends StatelessWidget {
  const ResetPassword01Block({super.key});

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
          child: const ResetPassword01Form(),
        ),
      ),
    ),
  );
}
