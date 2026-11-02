import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A titled stretch of the home desk: a big script heading, an optional
/// lede and [child] below.
///
/// Mirrors `DeskSection` in upstream `src/docs/content/home/section.tsx`.
class DeskSection extends StatelessWidget {
  const DeskSection({
    super.key,
    required this.title,
    this.lede,
    required this.child,
  });

  /// Widths from which the heading grows (upstream `@xl`).
  static const double roomyFrom = 576;

  final String title;
  final String? lede;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.only(top: Spacing.d96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: switch (constraints.maxWidth >= roomyFrom) {
                    true => 60,
                    false => 48,
                  },
                  cssLineHeight: 1.02,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
            ),
            if (lede case final text?)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.d12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 672),
                    child: Text(
                      text,
                      style: theme.typography.interface(
                        cssSize: 18,
                        color: theme.colors.inkSoft,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: Spacing.d40),
            child,
          ],
        ),
      ),
    );
  }
}
