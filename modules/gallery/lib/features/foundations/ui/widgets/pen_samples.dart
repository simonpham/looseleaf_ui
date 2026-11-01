import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The pens at work: underlines, a highlighter, a circle and a strike.
class PenSamples extends StatelessWidget {
  const PenSamples({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d32,
    runSpacing: Spacing.d24,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Underline(seed: 'pens-ink', child: Text('felt-tip ink')),
      Underline(
        tone: MarkPen.blue,
        kind: UnderlineMarkKind.wavy,
        seed: 'pens-blue',
        child: Text('blue felt'),
      ),
      Highlight(seed: 'pens-hi', child: Text('highlighter')),
      Circled(
        tone: MarkPen.red,
        seed: 'pens-red',
        child: Text('red pencil'),
      ),
      Strike(
        tone: MarkPen.pencil,
        seed: 'pens-pencil',
        child: Text('graphite'),
      ),
      Underline(
        tone: MarkPen.marker,
        weight: MarkWeight.brush,
        seed: 'pens-marker',
        child: Text('marker'),
      ),
    ],
  );
}
