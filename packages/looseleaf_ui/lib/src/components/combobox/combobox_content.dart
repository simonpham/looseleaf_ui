import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_popup_surface.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';

/// The popup of a [Combobox]: hangs 6 px under the trigger or field, as
/// wide as it (at least 208 px), and holds the search box and the list.
///
/// It shows while the combobox is open; a tap outside it or Escape closes
/// it. Its place in the tree does not matter: it is drawn in the nearest
/// [Overlay].
///
/// Mirrors `ComboboxContent` in upstream `src/components/ui/combobox.tsx`.
class ComboboxContent extends StatefulWidget {
  const ComboboxContent({
    super.key,
    required this.children,
    this.offset = ComboboxMetrics.sideOffset,
    this.width,
  });

  /// Usually a [ComboboxInput] (the search box) and a [ComboboxList].
  final List<Widget> children;

  /// The gap below the anchor (`sideOffset`).
  final double offset;

  /// A fixed width over the anchor's.
  final double? width;

  @override
  State<ComboboxContent> createState() => _ComboboxContentState();
}

class _ComboboxContentState extends State<ComboboxContent> {
  final OverlayPortalController _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    ComboboxScope.of(context);
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _popup,
      child: const SizedBox.shrink(),
    );
  }

  Widget _popup(BuildContext context) {
    final scope = ComboboxScope.of(context);
    final controller = scope.controller;
    if (!controller.open) return const SizedBox.shrink();
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: CompositedTransformFollower(
        link: controller.link,
        showWhenUnlinked: false,
        targetAnchor: switch (rtl) {
          true => Alignment.bottomRight,
          false => Alignment.bottomLeft,
        },
        followerAnchor: switch (rtl) {
          true => Alignment.topRight,
          false => Alignment.topLeft,
        },
        offset: Offset(0, widget.offset),
        child: TapRegion(
          groupId: controller.tapGroup,
          onTapOutside: (_) => controller.setOpen(false),
          child: TextFieldTapRegion(
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              label: controller.label ?? 'Options',
              child: ValueListenableBuilder(
                valueListenable: controller.anchorWidth,
                builder: (context, anchorWidth, child) => SizedBox(
                  width:
                      widget.width ??
                      math.max(
                        anchorWidth ?? 0,
                        ComboboxMetrics.contentMinWidth,
                      ),
                  child: child,
                ),
                child: ComboboxPopupSurface(
                  child: ComboboxScope(
                    controller: controller,
                    revision: scope.revision,
                    inContent: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.children,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
