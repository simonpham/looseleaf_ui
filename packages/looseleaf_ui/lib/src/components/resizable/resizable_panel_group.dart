import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/resizable/resizable.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Panels split by hand-stitched seams you can drag: [ResizablePanel]s with
/// a [ResizableHandle] between each pair. Groups nest.
///
/// ```dart
/// ResizablePanelGroup(children: [
///   ResizablePanel(defaultSize: 50, minSize: 20, child: One()),
///   ResizableHandle(withHandle: true, semanticLabel: 'Resize the first panel'),
///   ResizablePanel(defaultSize: 50, minSize: 20, child: Two()),
/// ])
/// ```
///
/// Mirrors `ResizablePanelGroup` in upstream
/// `src/components/ui/resizable.tsx` (react-resizable-panels' `Group`).
class ResizablePanelGroup extends StatefulWidget {
  const ResizablePanelGroup({
    super.key,
    required this.children,
    this.axis = Axis.horizontal,
    this.disabled = false,
    this.onLayout,
  });

  /// [ResizablePanel]s and [ResizableHandle]s, alternating.
  final List<Widget> children;

  /// [Axis.horizontal] lays panels side by side, [Axis.vertical] stacks
  /// them (upstream `orientation`).
  final Axis axis;

  /// Stops every seam from moving.
  final bool disabled;

  /// Called with the panels' sizes in percent as a seam moves.
  final ValueChanged<List<double>>? onLayout;

  /// A seam's thickness (`w-2` / `h-2`).
  static const double seam = Spacing.d8;

  @override
  State<ResizablePanelGroup> createState() => _ResizablePanelGroupState();
}

class _ResizablePanelGroupState extends State<ResizablePanelGroup> {
  List<double> _sizes = const [];
  double _available = 0;

  List<ResizablePanel> get _panels =>
      widget.children.whereType<ResizablePanel>().toList();

  void _syncSizes() {
    final panels = _panels;
    if (_sizes.length == panels.length) return;
    final given = panels.fold<double>(
      0,
      (sum, panel) => sum + (panel.defaultSize ?? 0),
    );
    final open = panels.where((panel) => panel.defaultSize == null).length;
    final share = switch (open) {
      0 => 0.0,
      _ => math.max(0, 100 - given) / open,
    };
    _sizes = [for (final panel in panels) panel.defaultSize ?? share];
  }

  (double, double) _limits(int seam) {
    final panels = _panels;
    final pair = _sizes[seam] + _sizes[seam + 1];
    final before = panels[seam];
    final after = panels[seam + 1];
    return (
      math.max(before.minSize, pair - after.maxSize),
      math.min(before.maxSize, pair - after.minSize),
    );
  }

  void _setSize(int seam, double size) {
    final (min, max) = _limits(seam);
    final pair = _sizes[seam] + _sizes[seam + 1];
    final next = size.clamp(min, max).toDouble();
    if (next == _sizes[seam]) return;
    setState(() {
      _sizes = [..._sizes]
        ..[seam] = next
        ..[seam + 1] = pair - next;
    });
    widget.onLayout?.call(List.unmodifiable(_sizes));
  }

  void _moveBy(int seam, double pixels) {
    if (_available <= 0) return;
    _setSize(seam, _sizes[seam] + pixels / _available * 100);
  }

  @override
  Widget build(BuildContext context) {
    _syncSizes();
    final handles = widget.children.whereType<ResizableHandle>().length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = switch (widget.axis) {
          Axis.horizontal => constraints.maxWidth,
          Axis.vertical => constraints.maxHeight,
        };
        _available = math.max(0, total - handles * ResizablePanelGroup.seam);
        var panel = 0;
        final children = <Widget>[];
        for (final child in widget.children) {
          if (child is ResizablePanel) {
            final extent = _available * _sizes[panel] / 100;
            children.add(
              switch (widget.axis) {
                Axis.horizontal => SizedBox(width: extent, child: child),
                Axis.vertical => SizedBox(height: extent, child: child),
              },
            );
            panel++;
            continue;
          }
          final seam = panel - 1;
          if (seam < 0 || seam + 1 >= _sizes.length) {
            children.add(child);
            continue;
          }
          final (min, max) = _limits(seam);
          children.add(
            ResizableScope(
              axis: widget.axis,
              disabled: widget.disabled,
              seam: seam,
              size: _sizes[seam],
              min: min,
              max: max,
              moveBy: (pixels) => _moveBy(seam, pixels),
              moveTo: (size) => _setSize(seam, size),
              child: child,
            ),
          );
        }
        return Flex(
          direction: widget.axis,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}
