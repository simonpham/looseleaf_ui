import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The page under the header, taking the height left: a typewriter
/// [kicker] over a script [title], then the [children].
///
/// Mirrors `PageBody` in upstream
/// `src/blocks/sidebar-shared/sidebar-page.tsx`.
class SidebarPageBody extends StatelessWidget {
  const SidebarPageBody({
    super.key,
    required this.title,
    this.kicker,
    this.children = const [],
  });

  final String title;
  final String? kicker;
  final List<Widget> children;

  /// Tailwind's `md`: from here the sides get 32 px.
  static const double _mediumWidth = 768;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final side = switch (MediaQuery.sizeOf(context).width >= _mediumWidth) {
      true => Spacing.d32,
      false => Spacing.d16,
    };
    final kicker = this.kicker;
    return Expanded(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          side,
          Spacing.d8,
          side,
          Spacing.d16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kicker != null)
                  Text(
                    kicker,
                    style: theme.typography
                        .face(
                          KevinSansFace.type,
                          cssSize: 14,
                          cssLineHeight: 20 / 14,
                          color: theme.colors.inkMuted,
                        )
                        .copyWith(
                          letterSpacing:
                              0.025 * 14 * KevinSansFace.type.sizeAdjust,
                        ),
                  ),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 30,
                      cssLineHeight: 1.25,
                      fontWeight: FontWeight.w600,
                      color: theme.colors.ink,
                    ),
                  ),
                ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
