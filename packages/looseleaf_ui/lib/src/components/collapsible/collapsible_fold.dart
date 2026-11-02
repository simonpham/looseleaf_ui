import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Unfolds [child] from nothing to its height when [open] turns on and
/// folds it away again, over `--ll-dur-sheet`; shut, the child is not
/// built. Upstream's `ll-collapsible-down` / `ll-accordion-down` keyframes.
class CollapsibleFold extends StatefulWidget {
  const CollapsibleFold({super.key, required this.open, required this.child});

  final bool open;
  final Widget child;

  @override
  State<CollapsibleFold> createState() => _CollapsibleFoldState();
}

class _CollapsibleFoldState extends State<CollapsibleFold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fold = AnimationController(
    vsync: this,
    duration: InkMotion.sheet,
    value: switch (widget.open) {
      true => 1,
      false => 0,
    },
  )..addStatusListener((_) => setState(() {}));

  late final Animation<double> _curve = CurvedAnimation(
    parent: _fold,
    curve: InkMotion.easeOut,
  );

  @override
  void didUpdateWidget(CollapsibleFold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open == widget.open) return;
    _fold.duration = InkMotion.of(context, InkMotion.sheet);
    if (widget.open) {
      _fold.forward();
      return;
    }
    _fold.reverse();
  }

  @override
  void dispose() {
    _fold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fold.isDismissed) return const SizedBox(width: double.infinity);
    return ClipRect(
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) => Align(
          alignment: Alignment.topCenter,
          heightFactor: math.max(_curve.value, 0),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
