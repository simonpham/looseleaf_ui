import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/shell/ui/widgets/logo_mark.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The phone nav: a pad sliding in from the start edge over a scrim.
/// Escape or a tap on the scrim closes it.
///
/// Mirrors `MobileNav` in upstream `src/docs/shell/NavPad.tsx`.
class NavDrawer extends StatelessWidget {
  const NavDrawer({
    super.key,
    required this.open,
    required this.onClose,
    required this.child,
  });

  final bool open;
  final VoidCallback onClose;

  /// The nav.
  final Widget child;

  static const double width = 288;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final duration = InkMotion.of(context, InkMotion.sheet);
    final drawerWidth = MediaQuery.sizeOf(context).width * 0.85;
    return IgnorePointer(
      ignoring: !open,
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): onClose},
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: onClose,
                child: AnimatedOpacity(
                  opacity: switch (open) {
                    true => 1,
                    false => 0,
                  },
                  duration: duration,
                  child: ColoredBox(
                    color: theme.colors.shade.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: AnimatedSlide(
                duration: duration,
                curve: InkMotion.easeOut,
                offset: switch ((open, Directionality.of(context))) {
                  (true, _) => Offset.zero,
                  (false, TextDirection.ltr) => const Offset(-1.05, 0),
                  (false, TextDirection.rtl) => const Offset(1.05, 0),
                },
                child: SizedBox(
                  width: switch (drawerWidth < width) {
                    true => drawerWidth,
                    false => width,
                  },
                  child: FocusScope(
                    autofocus: open,
                    child: Paper(
                      stock: StockName.pad,
                      tilt: false,
                      shadow: PaperShadow.lift,
                      seed: 'docs-drawer',
                      padding: const EdgeInsets.only(top: Spacing.d16),
                      child: SizedBox.expand(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.d16,
                              ),
                              child: Row(
                                spacing: Spacing.d8,
                                children: [
                                  const LogoMark(),
                                  Text(
                                    'Menu',
                                    style: theme.typography.title(cssSize: 24),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ScrollArea(
                                seed: 'docs-drawer|scroll',
                                child: Padding(
                                  padding: const EdgeInsets.all(Spacing.d8),
                                  child: child,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
