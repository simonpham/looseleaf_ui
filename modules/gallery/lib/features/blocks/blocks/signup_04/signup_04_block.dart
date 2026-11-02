import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/signup_04/signup_04.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A sign-up page: a wide card with the form and a welcome kit of stickers,
/// on a desk with a pencil.
///
/// Mirrors upstream `src/blocks/signup-04/page.tsx`.
class Signup04Block extends StatelessWidget {
  const Signup04Block({super.key});

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
            child: const Signup04Form(),
          ),
        ),
      );
    },
  );
}
