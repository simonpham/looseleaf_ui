import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The felt-tip underline under the strip that glides to the open tab and
/// stretches to fit it; shown only while a panel is open. Put it in a
/// [NavigationMenuList]'s children, after the items. Decorative.
///
/// Mirrors `NavigationMenuIndicator` in upstream
/// `src/components/ui/navigation-menu.tsx`.
class NavigationMenuIndicator extends StatefulWidget {
  const NavigationMenuIndicator({super.key, this.seed});

  /// The underline's height (upstream's `h-2`).
  static const double height = Spacing.d8;

  /// Pins the stroke.
  final String? seed;

  @override
  State<NavigationMenuIndicator> createState() =>
      _NavigationMenuIndicatorState();
}

class _NavigationMenuIndicatorState extends State<NavigationMenuIndicator>
    with InkSeed {
  Rect? _target;
  bool _scheduled = false;

  void _measure(NavigationMenuController? menu) {
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final next = _find(menu);
      if (next == _target) return;
      setState(() => _target = next);
    });
  }

  Rect? _find(NavigationMenuController? menu) {
    final value = menu?.value;
    if (menu == null || value == null) return _target;
    final tab = menu.triggerKey(value).currentContext?.findRenderObject();
    final self = context.findRenderObject();
    if (tab is! RenderBox || self is! RenderBox || !tab.attached) {
      return _target;
    }
    final origin = self.globalToLocal(tab.localToGlobal(Offset.zero));
    return origin & tab.size;
  }

  @override
  Widget build(BuildContext context) {
    final menu = NavigationMenu.maybeOf(context);
    _measure(menu);
    final target = _target;
    final shown = (menu?.isOpen ?? false) && target != null;
    final theme = LooseleafTheme.of(context);
    final tier = PaperInk.tier(theme);
    final calm = PaperInk.calm(theme);
    final seed = '${inkSeed(widget.seed)}|underline';
    final duration = InkMotion.of(context, InkMotion.sheet);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedOpacity(
          opacity: switch (shown) {
            true => 1,
            false => 0,
          },
          duration: InkMotion.of(context, InkMotion.fade),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (target != null)
                AnimatedPositioned(
                  duration: duration,
                  curve: InkMotion.settle,
                  left: target.left,
                  width: target.width,
                  top: 0,
                  height: NavigationMenuIndicator.height,
                  child: LayoutBuilder(
                    builder: (context, box) => InkArt(
                      cacheKey: [seed, tier.name, calm].join('|'),
                      size: Size(box.maxWidth, NavigationMenuIndicator.height),
                      color: theme.colors.inkYou,
                      draw: () => underlineMark(seed, tier: tier, calm: calm),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
