import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The site header under the announcement: the penmark word mark, the main
/// links (from 512 px wide) and a "Start free" button.
///
/// Mirrors upstream
/// `src/blocks/announcement-bar/components/announcement-bar-header.tsx`.
class AnnouncementBarHeader extends StatelessWidget {
  const AnnouncementBarHeader({super.key});

  static const _links = ['Product', 'Pricing', 'Notes', 'Sign in'];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d24,
          vertical: Spacing.d20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: Spacing.d16,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  const Mascot(size: 32),
                  Flexible(
                    child: Text(
                      'penmark',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 30,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (constraints.maxWidth >= 512)
              Semantics(
                container: true,
                label: 'Main',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d24,
                  children: [for (final link in _links) _NavLink(link)],
                ),
              ),
            Button(
              size: ButtonSize.sm,
              onPressed: () {},
              child: const Text('Start free'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink(this.label);

  final String label;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: Semantics(
          link: true,
          child: Text(
            widget.label,
            style: theme.typography
                .face(
                  KevinSansFace.hand,
                  cssSize: 16,
                  cssLineHeight: 24 / 16,
                  color: theme.colors.ink,
                )
                .copyWith(
                  decoration: switch (_hovered) {
                    true => TextDecoration.underline,
                    false => TextDecoration.none,
                  },
                  decorationColor: theme.colors.ink,
                ),
          ),
        ),
      ),
    );
  }
}
