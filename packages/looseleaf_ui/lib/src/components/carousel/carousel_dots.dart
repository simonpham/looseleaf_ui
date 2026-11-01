import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_scope.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_tick.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Where you are in a [Carousel], kept like a score: a tally tick per
/// slide in groups of five, the current one in blue. Tap a tick to go
/// there. One Tab stop, on the current tick; focus follows the slide.
///
/// Mirrors `CarouselDots` in upstream `src/components/ui/carousel.tsx`.
class CarouselDots extends StatefulWidget {
  const CarouselDots({super.key});

  @override
  State<CarouselDots> createState() => _CarouselDotsState();
}

class _CarouselDotsState extends State<CarouselDots> {
  final List<FocusNode> _nodes = [];
  int _selected = 0;

  void _sync(int count, int selected) {
    while (_nodes.length < count) {
      _nodes.add(FocusNode(debugLabel: 'CarouselTick ${_nodes.length}'));
    }
    while (_nodes.length > count) {
      _nodes.removeLast().dispose();
    }
    final focusIn = _nodes.any((node) => node.hasFocus);
    for (final (index, node) in _nodes.indexed) {
      node.skipTraversal = index != selected;
    }
    if (selected != _selected && focusIn && selected < _nodes.length) {
      _nodes[selected].requestFocus();
    }
    _selected = selected;
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = CarouselScope.maybeOf(context);
    final count = scope?.snapCount ?? 0;
    if (scope == null || count < 2) return const SizedBox.shrink();
    _sync(count, scope.selectedIndex);
    final groups = (count / 5).ceil();
    return Semantics(
      container: true,
      role: SemanticsRole.tabBar,
      label: 'Choose a slide',
      child: Padding(
        padding: const EdgeInsets.only(top: Spacing.d16),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.d8,
          children: [
            for (var group = 0; group < groups; group++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (
                    var index = group * 5;
                    index < (group + 1) * 5 && index < count;
                    index++
                  )
                    CarouselTick(
                      index: index,
                      selected: index == scope.selectedIndex,
                      seed: scope.seed,
                      focusNode: _nodes[index],
                      onSelect: () => scope.scrollTo(index),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
