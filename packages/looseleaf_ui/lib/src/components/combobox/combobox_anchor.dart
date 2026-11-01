import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_controller.dart';

/// Marks the widget a [ComboboxContent] hangs from: the trigger, the field
/// or the chips. Taps on it are not taps outside the popup, and its width
/// sets the popup's.
///
/// Mirrors upstream's `PopoverAnchor` / `PopoverTrigger` around those parts.
class ComboboxAnchor extends StatelessWidget {
  const ComboboxAnchor({
    super.key,
    required this.controller,
    required this.child,
  });

  final ComboboxController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: controller.link,
    child: TapRegion(
      groupId: controller.tapGroup,
      child: _WidthReport(width: controller.anchorWidth, child: child),
    ),
  );
}

class _WidthReport extends SingleChildRenderObjectWidget {
  const _WidthReport({required this.width, super.child});

  final ValueNotifier<double?> width;

  @override
  _RenderWidthReport createRenderObject(BuildContext context) =>
      _RenderWidthReport(width);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderWidthReport renderObject,
  ) {
    renderObject.width = width;
  }
}

class _RenderWidthReport extends RenderProxyBox {
  _RenderWidthReport(this.width);

  ValueNotifier<double?> width;

  @override
  void performLayout() {
    super.performLayout();
    final measured = size.width;
    if (width.value == measured) return;
    final target = width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) target.value = measured;
    });
  }
}
