import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/login_05/login_05.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A passwordless sign-in on a plain sheet of paper: no card, Stubby
/// waving, and one field that emails a link.
///
/// Mirrors upstream `src/blocks/login-05/page.tsx`.
class Login05Block extends StatelessWidget {
  const Login05Block({super.key});

  static const double _maxWidth = 384;
  static const double _minHeight = 640;
  static const double _wideFrom = 576;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Paper(
      tilt: false,
      shadow: PaperShadow.none,
      seed: 'login-05',
      padding: EdgeInsets.all(switch (constraints.maxWidth >= _wideFrom) {
        true => Spacing.d40,
        false => Spacing.d24,
      }),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          minHeight: _minHeight - Spacing.d80,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: const Login05Form(),
          ),
        ),
      ),
    ),
  );
}
