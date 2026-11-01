import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// The shared slip the open panel is written on: a slip of paper (tilted
/// 0.3°, lifted) that resizes to the open [NavigationMenuContent] and
/// clips it, while the panels slide in from the side of the item they come
/// from. [NavigationMenu] puts it under the strip; it keeps showing the
/// last panel while it leaves.
///
/// Mirrors `NavigationMenuViewport` in upstream
/// `src/components/ui/navigation-menu.tsx`.
class NavigationMenuViewport extends StatefulWidget {
  const NavigationMenuViewport({super.key, this.seed});

  /// Pins the slip.
  final String? seed;

  /// How far a panel slides in (upstream's `slide-in-from-right-52`).
  static const double slide = 208;

  @override
  State<NavigationMenuViewport> createState() => _NavigationMenuViewportState();
}

class _NavigationMenuViewportState extends State<NavigationMenuViewport>
    with InkSeed {
  String? _shown;
  int _direction = 0;

  void _follow(NavigationMenuController controller) {
    final value = controller.value;
    if (value == null || value == _shown) return;
    final from = controller.indexOf(_shown);
    final to = controller.indexOf(value);
    _direction = switch (from < 0 || to < 0) {
      true => 0,
      false => (to - from).sign,
    };
    _shown = value;
  }

  @override
  Widget build(BuildContext context) {
    final controller = NavigationMenu.of(context);
    _follow(controller);
    final shown = _shown;
    final content = controller.contentOf(shown);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final reading = switch (rtl) {
      true => -1,
      false => 1,
    };
    final duration = InkMotion.of(context, InkMotion.sheet);
    return MouseRegion(
      onEnter: (_) => controller.stay(),
      onExit: (_) => controller.leave(),
      child: PaperPopup(
        seed: inkSeed(widget.seed),
        tiltDegrees: 0.3,
        child: Focus(
          focusNode: controller.panelFocus,
          child: ClipRect(
            child: AnimatedSize(
              duration: duration,
              curve: InkMotion.easeOut,
              alignment: AlignmentDirectional.topStart,
              child: AnimatedSwitcher(
                duration: duration,
                switchInCurve: InkMotion.easeOut,
                switchOutCurve: InkMotion.easeOut,
                layoutBuilder: (current, previous) => Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: [
                    for (final old in previous) Positioned(child: old),
                    ?current,
                  ],
                ),
                transitionBuilder: (child, animation) {
                  final incoming = child.key == ValueKey(shown);
                  final side = switch (incoming) {
                    true => _direction,
                    false => -_direction,
                  };
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                        (1 - animation.value) *
                            side *
                            reading *
                            NavigationMenuViewport.slide,
                        0,
                      ),
                      child: Opacity(opacity: animation.value, child: child),
                    ),
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(shown),
                  child: content ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
