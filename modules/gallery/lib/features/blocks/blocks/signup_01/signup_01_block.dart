import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/signup_01/signup_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A sign-up page: the clipped sign-up card alone in the middle of the desk.
///
/// Mirrors upstream `src/blocks/signup-01/page.tsx`.
class Signup01Block extends StatelessWidget {
  const Signup01Block({super.key});

  static const double _maxWidth = 384;
  static const double _wideFrom = 576;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: switch (constraints.maxWidth >= _wideFrom) {
        true => const EdgeInsets.fromLTRB(
          Spacing.d40,
          Spacing.d56,
          Spacing.d40,
          Spacing.d40,
        ),
        false => const EdgeInsets.fromLTRB(
          Spacing.d24,
          Spacing.d56,
          Spacing.d24,
          Spacing.d24,
        ),
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: const Signup01Form(),
        ),
      ),
    ),
  );
}
