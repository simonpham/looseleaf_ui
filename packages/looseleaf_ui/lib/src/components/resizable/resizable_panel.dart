import 'package:flutter/widgets.dart';

/// One panel of a [ResizablePanelGroup], sized in percent of the group.
///
/// Mirrors `ResizablePanel` in upstream `src/components/ui/resizable.tsx`
/// (react-resizable-panels' `Panel`).
class ResizablePanel extends StatelessWidget {
  const ResizablePanel({
    super.key,
    required this.child,
    this.defaultSize,
    this.minSize = 0,
    this.maxSize = 100,
  });

  final Widget child;

  /// The starting size in percent; panels without one share what is left.
  final double? defaultSize;

  /// The smallest size in percent.
  final double minSize;

  /// The largest size in percent.
  final double maxSize;

  @override
  Widget build(BuildContext context) => child;
}
