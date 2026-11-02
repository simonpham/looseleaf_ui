import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// The phone sidebar: [child] slid in from [side] over the full height,
/// [width] wide, above the warm scrim. A modal dialog named "Sidebar": it
/// traps focus, closes on Escape or a tap on the scrim, and gives focus
/// back to whatever had it.
///
/// Mirrors the `Sheet` branch of `Sidebar` in upstream
/// `src/components/ui/sidebar.tsx` (`SheetContent` with `side`,
/// `slide-in-from-*` over `--ll-dur-sheet`).
class SidebarSheet extends StatefulWidget {
  const SidebarSheet({
    super.key,
    required this.open,
    required this.onOpenChange,
    required this.side,
    required this.width,
    required this.child,
  });

  /// Whether the sheet is open.
  final bool open;

  /// Called when it asks to close.
  final ValueChanged<bool> onOpenChange;

  /// The edge it slides in from.
  final SidebarSide side;

  /// The sheet's width.
  final double width;

  /// The pad.
  final Widget child;

  @override
  State<SidebarSheet> createState() => _SidebarSheetState();
}

class _SidebarSheetState extends State<SidebarSheet>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _motion;
  late final Animation<double> _slide = CurvedAnimation(
    parent: _motion,
    curve: InkMotion.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this);
    if (widget.open) _show();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion.duration = InkMotion.of(context, InkMotion.sheet);
  }

  @override
  void didUpdateWidget(SidebarSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open == oldWidget.open) return;
    if (widget.open) {
      _show();
      return;
    }
    unawaited(_hide());
  }

  void _show() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.open) return;
      _portal.show();
      unawaited(_motion.forward());
    });
  }

  Future<void> _hide() async {
    await _motion.reverse().orCancel.catchError((_) {});
    if (!mounted || widget.open) return;
    _portal.hide();
  }

  void _close() {
    if (widget.open) widget.onOpenChange(false);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Widget _sheet(BuildContext context) {
    final from = switch (widget.side) {
      SidebarSide.left => const Offset(-1, 0),
      SidebarSide.right => const Offset(1, 0),
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        OverlayScrim(opacity: _motion, onDismiss: _close),
        Positioned(
          top: 0,
          bottom: 0,
          width: widget.width,
          left: switch (widget.side) {
            SidebarSide.left => 0,
            SidebarSide.right => null,
          },
          right: switch (widget.side) {
            SidebarSide.left => null,
            SidebarSide.right => 0,
          },
          child: IgnorePointer(
            ignoring: !widget.open,
            child: OverlayDismiss(
              escape: widget.open,
              outside: false,
              onDismiss: (_) => _close(),
              child: OverlayFocus(
                autofocus: true,
                trapped: true,
                restoreFocus: true,
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  label: 'Sidebar',
                  hint: 'Displays the mobile sidebar.',
                  child: SlideTransition(
                    position: Tween(
                      begin: from,
                      end: Offset.zero,
                    ).animate(_slide),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayChildBuilder: _sheet,
    child: const SizedBox.shrink(),
  );
}
