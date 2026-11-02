import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalloutDirectionsExample extends StatelessWidget {
  const CalloutDirectionsExample({super.key});

  static const _wide = 640.0;
  static const _notes = [
    (ArrowDirection.left, 'check the date!'),
    (ArrowDirection.right, 'ask sam'),
    (ArrowDirection.up, 'this again?'),
    (ArrowDirection.down, 'so true'),
    (ArrowDirection.upLeft, 'nice one'),
    (ArrowDirection.upRight, 'wait, why?'),
    (ArrowDirection.downLeft, 'move this up'),
    (ArrowDirection.downRight, 'the best line'),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = switch (constraints.maxWidth >= _wide) {
        true => 4,
        false => 2,
      };
      final width =
          (constraints.maxWidth - Spacing.d40 * (columns - 1)) / columns -
          Spacing.d1;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
        child: Wrap(
          spacing: Spacing.d40,
          runSpacing: Spacing.d32,
          children: [
            for (final (index, (direction, text)) in _notes.indexed)
              SizedBox(
                width: width,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Callout(
                    text,
                    direction: direction,
                    seed: 'd$index',
                    curve: switch (index) {
                      6 => ArrowCurve.curl,
                      _ => ArrowCurve.curved,
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
