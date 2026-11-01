import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Wraps a group's [SidebarMenu] in small text (`text-sm`).
///
/// Mirrors `SidebarGroupContent` in upstream `src/components/ui/sidebar.tsx`.
class SidebarGroupContent extends StatelessWidget {
  const SidebarGroupContent({super.key, required this.child});

  /// Usually a [SidebarMenu].
  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: LooseleafTheme.of(
      context,
    ).typography.face(KevinSansFace.hand, cssSize: 14, cssLineHeight: 20 / 14),
    child: child,
  );
}
