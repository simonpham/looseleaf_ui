import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A bold [title] over a muted [subtitle], each cut short to one line.
/// Hidden when the sidebar is collapsed to icons.
///
/// Mirrors `BrandText` in upstream `src/blocks/sidebar-shared/sidebar-brand.tsx`.
class BrandText extends StatelessWidget {
  const BrandText({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    if (SidebarPanelScope.iconsOf(context)) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    final subtitle = this.subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 14,
            cssLineHeight: 1.25,
            fontWeight: FontWeight.w700,
            color: theme.colors.ink,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              cssLineHeight: 1.25,
              color: theme.colors.inkMuted,
            ),
          ),
      ],
    );
  }
}
