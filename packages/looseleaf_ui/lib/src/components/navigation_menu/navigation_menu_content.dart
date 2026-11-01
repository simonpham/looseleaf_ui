import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A panel's contents, 8 px in (10 at the end). In the shared viewport it
/// slides between items, clipped to the slip; without the viewport it is a
/// flat slip of its own. [NavigationMenuLink]s inside it are rows.
///
/// Mirrors `NavigationMenuContent` in upstream
/// `src/components/ui/navigation-menu.tsx`.
class NavigationMenuContent extends StatefulWidget {
  const NavigationMenuContent({
    super.key,
    required this.child,
    this.width,
    this.seed,
  });

  /// The panel: rows of links, a featured card, columns.
  final Widget child;

  /// A fixed width (upstream's `w-[500px]` on the list inside).
  final double? width;

  /// Pins the slip when it has its own.
  final String? seed;

  @override
  State<NavigationMenuContent> createState() => _NavigationMenuContentState();
}

class _NavigationMenuContentState extends State<NavigationMenuContent>
    with InkSeed {
  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        Spacing.d8,
        Spacing.d8,
        Spacing.d10,
        Spacing.d8,
      ),
      child: SizedBox(
        width: widget.width,
        child: NavigationMenuPanelScope(child: widget.child),
      ),
    );
    final shared = NavigationMenu.maybeOf(context)?.viewport ?? true;
    if (shared) return body;
    return PaperPopup(seed: inkSeed(widget.seed), tilt: false, child: body);
  }
}
