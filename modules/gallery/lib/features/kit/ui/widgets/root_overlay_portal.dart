import 'package:flutter/widgets.dart';

/// An [OverlayPortal] whose overlay child goes on the root [Overlay], over
/// the whole window.
class RootOverlayPortal extends StatelessWidget {
  const RootOverlayPortal({
    super.key,
    required this.controller,
    required this.overlayChildBuilder,
    required this.child,
  });

  final OverlayPortalController controller;
  final WidgetBuilder overlayChildBuilder;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      // `overlayLocation` replaces this on newer Flutter but is missing on 3.32.
      // ignore: deprecated_member_use
      OverlayPortal.targetsRootOverlay(
        controller: controller,
        overlayChildBuilder: overlayChildBuilder,
        child: child,
      );
}
