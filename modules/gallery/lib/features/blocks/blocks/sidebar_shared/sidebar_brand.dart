import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The app's name at the top of the pad: a large row with a [BrandTile]
/// and the [title] over a [subtitle].
///
/// Mirrors `SidebarBrand` in upstream
/// `src/blocks/sidebar-shared/sidebar-brand.tsx`.
class SidebarBrand extends StatelessWidget {
  const SidebarBrand({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onPressed,
  });

  final String title;
  final String? subtitle;
  final String icon;

  /// Called when the row is tapped; it goes home.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SidebarMenu(
    children: [
      SidebarMenuItem(
        child: SidebarMenuButton(
          size: SidebarMenuButtonSize.lg,
          leading: BrandTile(icon: icon),
          onPressed: onPressed ?? () {},
          child: BrandText(title: title, subtitle: subtitle),
        ),
      ),
    ],
  );
}
