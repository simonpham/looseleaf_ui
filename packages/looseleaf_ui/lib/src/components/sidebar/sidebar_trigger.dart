import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A 28 px ghost icon [Button] with a drawn panel glyph that toggles the
/// sidebar (the sheet on phones). Named "Toggle Sidebar".
///
/// Mirrors `SidebarTrigger` in upstream `src/components/ui/sidebar.tsx`.
class SidebarTrigger extends StatelessWidget {
  const SidebarTrigger({
    super.key,
    this.onPressed,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// Called before the toggle.
  final VoidCallback? onPressed;

  /// Pins the button's hand.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    final data = SidebarProvider.of(context);
    return SizedBox.square(
      dimension: Spacing.d28,
      child: Button(
        variant: ButtonVariant.ghost,
        size: ButtonSize.icon,
        seed: seed,
        focusNode: focusNode,
        autofocus: autofocus,
        forcedStates: forcedStates,
        semanticLabel: 'Toggle Sidebar',
        onPressed: () {
          onPressed?.call();
          data.toggleSidebar();
        },
        child: const InkIcon('panel-left'),
      ),
    );
  }
}
