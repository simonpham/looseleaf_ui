import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One link in the side nav: hand text that gets a highlighter swipe on
/// hover, and keeps it, bold, on the current page.
///
/// Mirrors `NavItem` in upstream `src/docs/kit/Nav.tsx`.
class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.label,
    required this.active,
    required this.onPressed,
    this.nested = false,
    this.leading,
    this.trailing,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  /// A row inside a group: a little smaller.
  final bool nested;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DocPressable(
      onPressed: onPressed,
      selected: active,
      builder: (context, highlighted) => SizedBox(
        height: switch (nested) {
          true => Spacing.d28,
          false => Spacing.d32,
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
          child: Row(
            spacing: Spacing.d6,
            children: [
              ?leading,
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Highlight(
                    show: highlighted || active,
                    seed: 'nav:$label',
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.face(
                        KevinSansFace.hand,
                        cssSize: switch (nested) {
                          true => 14.5,
                          false => 15.5,
                        },
                        cssLineHeight: 1.3,
                        fontWeight: switch (active) {
                          true => FontWeight.w700,
                          false => FontWeight.w400,
                        },
                        color: switch (active || highlighted) {
                          true => theme.colors.ink,
                          false => theme.colors.inkSoft,
                        },
                      ),
                    ),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
