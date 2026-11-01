import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A page above this one. Pointing at it, or focusing it from the
/// keyboard, lays a highlighter swipe under it (upstream `ll-swipe`).
///
/// Mirrors `BreadcrumbLink` in upstream `src/components/ui/breadcrumb.tsx`.
class BreadcrumbLink extends StatelessWidget {
  const BreadcrumbLink({
    super.key,
    required this.child,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  final Widget child;

  /// Called on tap and Enter.
  final VoidCallback? onPressed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  /// `ll-swipe`'s `border-radius: 3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius swipeCorners = BorderRadius.only(
    topLeft: Radius.elliptical(3, Spacing.d8),
    topRight: Radius.elliptical(Spacing.d8, 3),
    bottomRight: Radius.elliptical(Spacing.d4, 9),
    bottomLeft: Radius.elliptical(9, Spacing.d4),
  );

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    link: true,
    child: InkInteraction(
      onActivate: onPressed,
      states: forcedStates,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (context, states) {
        final theme = LooseleafTheme.of(context);
        final swiped =
            states.contains(InkState.hovered) ||
            states.contains(InkState.focused);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -Spacing.d4,
              right: -Spacing.d4,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: InkMotion.of(context, InkMotion.hover),
                decoration: BoxDecoration(
                  color: switch (swiped) {
                    true => theme.colors.hiSelect,
                    false => theme.colors.hiSelect.withValues(alpha: 0),
                  },
                  borderRadius: swipeCorners,
                ),
              ),
            ),
            DefaultTextStyle.merge(
              style: TextStyle(
                color: switch (swiped) {
                  true => theme.colors.selectionText,
                  false => null,
                },
              ),
              child: child,
            ),
          ],
        );
      },
    ),
  );
}
