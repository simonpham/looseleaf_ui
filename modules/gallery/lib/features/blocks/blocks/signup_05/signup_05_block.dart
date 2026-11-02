import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/signup_05/signup_05.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A sign-up page: a torn-off pad sheet rising from the bottom of the desk,
/// with a one-field email sign-up on it. The sheet runs off the bottom.
///
/// Mirrors upstream `src/blocks/signup-05/page.tsx`.
class Signup05Block extends StatelessWidget {
  const Signup05Block({super.key});

  static const double _minHeight = 680;
  static const double _sheetWidth = 672;
  static const double _formWidth = 384;
  static const double _wideFrom = 576;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= _wideFrom;
      final sheetPadding = switch (wide) {
        true => Spacing.d48,
        false => Spacing.d24,
      };
      return ClipRect(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            switch (wide) {
              true => Spacing.d40,
              false => Spacing.d16,
            },
            Spacing.d40,
            switch (wide) {
              true => Spacing.d40,
              false => Spacing.d16,
            },
            0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _sheetWidth),
              child: Transform.translate(
                offset: const Offset(0, Spacing.d16),
                child: Paper(
                  stock: StockName.pad,
                  rules: RuleName.none,
                  edge: const EdgeSpec(top: EdgeKind.torn),
                  tilt: false,
                  seed: 'signup-05-sheet',
                  padding: EdgeInsets.symmetric(
                    horizontal: sheetPadding,
                    vertical: Spacing.d48,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: _minHeight - Spacing.d40 - Spacing.d48 * 2,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: _formWidth),
                        child: const Signup05Form(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
