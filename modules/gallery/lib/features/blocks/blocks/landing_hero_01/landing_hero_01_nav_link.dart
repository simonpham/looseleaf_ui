import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A main-menu link in the hero's header: 16 px ink text that gets a
/// highlighter swipe on hover.
class LandingHero01NavLink extends StatefulWidget {
  const LandingHero01NavLink(this.label, {super.key, this.onPressed});

  /// The link's text.
  final String label;

  /// Called on tap.
  final VoidCallback? onPressed;

  @override
  State<LandingHero01NavLink> createState() => _LandingHero01NavLinkState();
}

class _LandingHero01NavLinkState extends State<LandingHero01NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed ?? () {},
        child: Semantics(
          link: true,
          child: SidebarSwipe(
            on: _hovered,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.d12,
                vertical: Spacing.d4,
              ),
              child: Text(
                widget.label,
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 16,
                  cssLineHeight: 24 / 16,
                  color: theme.colors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
