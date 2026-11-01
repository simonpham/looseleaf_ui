import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/shell/ui/widgets/logo_mark.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The slip of paper across the top: the nav toggle, the logo, the
/// [primary] links (wide screens only) and the [settings] button.
///
/// Mirrors `TopBar` in upstream `src/docs/shell/TopBar.tsx`.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.compact,
    required this.onToggleNav,
    required this.onHome,
    required this.primary,
    required this.settings,
  });

  /// The phone layout: a menu icon and no primary links.
  final bool compact;
  final VoidCallback onToggleNav;
  final VoidCallback onHome;
  final List<Widget> primary;
  final Widget settings;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Paper(
      stock: StockName.slip,
      tilt: false,
      shadow: PaperShadow.loose,
      seed: 'docs-topbar',
      padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
      child: SizedBox(
        height: Spacing.d48,
        child: Row(
          spacing: Spacing.d4,
          children: [
            Button(
              variant: ButtonVariant.ghost,
              size: ButtonSize.icon,
              semanticLabel: switch (compact) {
                true => 'Menu',
                false => 'Toggle navigation',
              },
              onPressed: onToggleNav,
              child: InkIcon(switch (compact) {
                true => 'menu',
                false => 'panel-left',
              }, size: Spacing.d20),
            ),
            DocPressable(
              onPressed: onHome,
              semanticLabel: 'Looseleaf home',
              builder: (context, highlighted) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
                child: Row(
                  spacing: Spacing.d6,
                  children: [
                    AnimatedRotation(
                      turns: switch (highlighted) {
                        true => -6 / 360,
                        false => 0,
                      },
                      duration: InkMotion.of(context, InkMotion.pop),
                      curve: InkMotion.popCurve,
                      child: const LogoMark(),
                    ),
                    Text(
                      'Looseleaf',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 30.4,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!compact)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: Spacing.d12),
                child: Row(spacing: Spacing.d2, children: primary),
              ),
            const Spacer(),
            settings,
          ],
        ),
      ),
    );
  }
}
