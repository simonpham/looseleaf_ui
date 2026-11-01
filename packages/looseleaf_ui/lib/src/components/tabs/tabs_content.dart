import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/tabs/tabs_scope.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// The panel of one tab: built only while its tab is open, and faded in
/// over `--ll-dur-fade` as it opens.
///
/// Mirrors `TabsContent` in upstream `src/components/ui/tabs.tsx`.
class TabsContent extends StatelessWidget {
  const TabsContent({super.key, required this.value, required this.child});

  /// The [TabsTrigger] that opens it.
  final String value;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (TabsScope.maybeOf(context)?.value != value) {
      return const SizedBox.shrink();
    }
    return Semantics(
      container: true,
      role: SemanticsRole.tabPanel,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(value),
        tween: Tween(begin: 0, end: 1),
        duration: InkMotion.of(context, InkMotion.fade),
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
        child: child,
      ),
    );
  }
}
