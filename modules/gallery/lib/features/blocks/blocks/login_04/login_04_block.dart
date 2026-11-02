import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/login_04/login_04.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A sign-in card on the desk that widens into two columns, with polaroids
/// on a kraft panel beside the form.
///
/// Mirrors upstream `src/blocks/login-04/page.tsx`.
class Login04Block extends StatelessWidget {
  const Login04Block({super.key});

  static const double _maxWidth = 384;
  static const double _wideMaxWidth = 896;
  static const double _paddedFrom = 576;
  static const double _wideFrom = 768;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      return Padding(
        padding: EdgeInsets.all(switch (width >= _paddedFrom) {
          true => Spacing.d40,
          false => Spacing.d24,
        }),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: switch (width >= _wideFrom) {
                true => _wideMaxWidth,
                false => _maxWidth,
              },
            ),
            child: const Login04Form(),
          ),
        ),
      );
    },
  );
}
