import 'dart:ui' show lerpDouble;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An order pad hung at the edge of the screen: cream paper with a torn top
/// edge and a binder clip, holding a [SidebarHeader], a scrolling
/// [SidebarContent] and a [SidebarFooter].
///
/// Inside a [SidebarProvider] it slides off the screen
/// ([SidebarCollapsible.offcanvas]), shrinks to icons
/// ([SidebarCollapsible.icon]) or stays ([SidebarCollapsible.none]).
/// Below the mobile breakpoint it opens as a sheet from its [side]: a
/// dialog named "Sidebar" on the warm scrim that traps focus, closes on
/// Escape or a tap outside and gives focus back.
///
/// ```dart
/// Sidebar(
///   collapsible: SidebarCollapsible.icon,
///   rail: const SidebarRail(),
///   children: [
///     SidebarHeader(children: [...]),
///     SidebarContent(children: [...]),
///   ],
/// )
/// ```
///
/// Mirrors `Sidebar` in upstream `src/components/ui/sidebar.tsx`.
class Sidebar extends StatefulWidget {
  const Sidebar({
    super.key,
    required this.children,
    this.side = SidebarSide.left,
    this.variant = SidebarVariant.sidebar,
    this.collapsible = SidebarCollapsible.offcanvas,
    this.stock = StockName.pad,
    this.clip,
    this.rail,
    this.seed,
  });

  /// The pad's parts, top to bottom.
  final List<Widget> children;

  /// The edge it hangs on.
  final SidebarSide side;

  /// Docked, floating or inset.
  final SidebarVariant variant;

  /// What collapsing does.
  final SidebarCollapsible collapsible;

  /// What the pad is made of.
  final StockName stock;

  /// The binder clip; on unless [collapsible] is
  /// [SidebarCollapsible.none]. Never drawn in calm density or collapsed
  /// to icons.
  final bool? clip;

  /// A [SidebarRail] on the pad's page edge.
  final Widget? rail;

  /// Pins the tear, tooth and clip.
  final String? seed;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with InkSeed {
  static const double _railHalf = SidebarMetrics.rail / 2;

  bool get _clip =>
      widget.clip ?? widget.collapsible != SidebarCollapsible.none;

  void _report(SidebarScope? scope, SidebarVariant? variant) {
    if (scope == null || scope.dockedVariant.value == variant) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      scope.dockedVariant.value = variant;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SidebarScope>();
    final data = scope?.data;
    final seed = inkSeed(widget.seed);
    if (widget.collapsible == SidebarCollapsible.none || data == null) {
      _report(scope, null);
      return _static(seed);
    }
    if (data.isMobile) {
      _report(scope, null);
      return SidebarSheet(
        open: data.openMobile,
        onOpenChange: data.setOpenMobile,
        side: widget.side,
        width:
            SidebarProvider.widgetOf(context)?.widthMobile ??
            SidebarMetrics.widthMobile,
        child: SidebarPanelScope(
          side: widget.side,
          collapsedToIcons: false,
          offcanvasCollapsed: false,
          mobile: true,
          child: SidebarPad(
            stock: widget.stock,
            seed: seed,
            clip: switch (_clip) {
              true => SidebarClipPlace.inside,
              false => SidebarClipPlace.none,
            },
            topPadding: switch (_clip) {
              true => SidebarMetrics.insideClipPad,
              false => Spacing.d8,
            },
            children: widget.children,
          ),
        ),
      );
    }
    _report(scope, widget.variant);
    return TweenAnimationBuilder<double>(
      tween: Tween(
        end: switch (data.open) {
          true => 1,
          false => 0,
        },
      ),
      duration: InkMotion.of(context, InkMotion.sheet),
      curve: InkMotion.easeOut,
      builder: (context, t, _) => _docked(context, data, seed, t),
    );
  }

  Widget _static(String seed) => SizedBox(
    width: SidebarProvider.widgetOf(context)?.width ?? SidebarMetrics.width,
    child: SidebarPanelScope(
      side: widget.side,
      collapsedToIcons: false,
      offcanvasCollapsed: false,
      mobile: false,
      child: SidebarPad(
        stock: widget.stock,
        seed: seed,
        clip: switch (_clip) {
          true => SidebarClipPlace.inside,
          false => SidebarClipPlace.none,
        },
        topPadding: switch (_clip) {
          true => SidebarMetrics.insideClipPad,
          false => 0,
        },
        children: widget.children,
      ),
    ),
  );

  Widget _docked(
    BuildContext context,
    SidebarData data,
    String seed,
    double t,
  ) {
    final provider = SidebarProvider.widgetOf(context);
    final width = provider?.width ?? SidebarMetrics.width;
    final icon = provider?.widthIcon ?? SidebarMetrics.widthIcon;
    final spaced = widget.variant != SidebarVariant.sidebar;
    final iconGap = switch (spaced) {
      true => icon + Spacing.d16,
      false => icon,
    };
    final iconContainer = switch (spaced) {
      true => iconGap + Spacing.d2,
      false => icon,
    };
    final offcanvas = widget.collapsible == SidebarCollapsible.offcanvas;
    final gap = switch (offcanvas) {
      true => width * t,
      false => lerpDouble(iconGap, width, t) ?? width,
    };
    final container = switch (offcanvas) {
      true => width,
      false => lerpDouble(iconContainer, width, t) ?? width,
    };
    final start = switch ((widget.side, offcanvas)) {
      (SidebarSide.left, true) => -width * (1 - t),
      (SidebarSide.left, false) => 0.0,
      (SidebarSide.right, _) =>
        gap -
            container +
            switch (offcanvas) {
              true => width * (1 - t),
              false => 0.0,
            },
    };
    final padding = switch (spaced) {
      true => const EdgeInsets.fromLTRB(
        Spacing.d8,
        SidebarMetrics.gutter,
        Spacing.d8,
        Spacing.d8,
      ),
      false => const EdgeInsets.only(top: SidebarMetrics.gutter),
    };
    final collapsed = !data.open;
    final rail = widget.rail;
    return SidebarDock(
      gap: gap,
      containerWidth: container + 2 * _railHalf,
      offset: start - _railHalf,
      child: SidebarPanelScope(
        side: widget.side,
        collapsedToIcons:
            collapsed && widget.collapsible == SidebarCollapsible.icon,
        offcanvasCollapsed: collapsed && offcanvas,
        mobile: false,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding:
                  padding + const EdgeInsets.symmetric(horizontal: _railHalf),
              child: SidebarPad(
                stock: widget.stock,
                seed: seed,
                tilt: widget.variant == SidebarVariant.floating,
                dockedSide: switch (widget.variant) {
                  SidebarVariant.sidebar => widget.side,
                  _ => null,
                },
                clip: switch (_clip) {
                  true => SidebarClipPlace.hanging,
                  false => SidebarClipPlace.none,
                },
                topPadding: switch (_clip) {
                  true => SidebarMetrics.clipPad,
                  false => 0,
                },
                children: widget.children,
              ),
            ),
            if (rail != null)
              Positioned(
                top: padding.top,
                bottom: padding.bottom,
                width: SidebarMetrics.rail,
                left: switch (widget.side) {
                  SidebarSide.left => null,
                  SidebarSide.right => padding.left,
                },
                right: switch (widget.side) {
                  SidebarSide.left => padding.right,
                  SidebarSide.right => null,
                },
                child: rail,
              ),
          ],
        ),
      ),
    );
  }
}
