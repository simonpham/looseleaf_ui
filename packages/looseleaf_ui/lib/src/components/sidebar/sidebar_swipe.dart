import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/breadcrumb/breadcrumb.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Lays upstream's `ll-swipe` under [child] while [on]: a highlighter
/// wash with uneven corners, fading in over the hover duration.
class SidebarSwipe extends StatelessWidget {
  const SidebarSwipe({super.key, required this.on, required this.child});

  /// Whether the wash shows.
  final bool on;

  /// What sits on the wash.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return AnimatedContainer(
      duration: InkMotion.of(context, InkMotion.hover),
      decoration: BoxDecoration(
        color: switch (on) {
          true => colors.hiSelect,
          false => colors.hiSelect.withValues(alpha: 0),
        },
        borderRadius: BreadcrumbLink.swipeCorners,
      ),
      child: child,
    );
  }
}
