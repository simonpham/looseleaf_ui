import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/signup_03/signup_03.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A sign-up page: the Looseleaf name over a centred card, on a desk with
/// clips and pins.
///
/// Mirrors upstream `src/blocks/signup-03/page.tsx`.
class Signup03Block extends StatelessWidget {
  const Signup03Block({super.key});

  static const double _maxWidth = 384;
  static const double _wideFrom = 576;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: EdgeInsets.all(switch (constraints.maxWidth >= _wideFrom) {
          true => Spacing.d40,
          false => Spacing.d24,
        }),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Column(
              spacing: Spacing.d24,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d8,
                  children: [
                    const InkIcon(
                      'book-open',
                      tone: ArtTone.doodle,
                      size: Spacing.d24,
                    ),
                    Text(
                      'Looseleaf',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 24,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                  ],
                ),
                const Signup03Form(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
