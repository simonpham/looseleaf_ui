import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-xl`.
const _maxWidth = 576.0;

/// Below this width the list is two columns (`sm:grid-cols-4`).
const _fourColumns = 480.0;

const _types = [
  (type: AnnotateType.highlight, word: 'swipe'),
  (type: AnnotateType.underline, word: 'line'),
  (type: AnnotateType.circle, word: 'loop'),
  (type: AnnotateType.box, word: 'box'),
  (type: AnnotateType.brackets, word: 'brackets'),
  (type: AnnotateType.strikeThrough, word: 'struck'),
  (type: AnnotateType.crossedOff, word: 'crossed off'),
  (type: AnnotateType.scribble, word: 'scribbled'),
];

class AnnotateEveryTypeExample extends StatelessWidget {
  const AnnotateEveryTypeExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = switch (constraints.maxWidth < _fourColumns) {
              true => 2,
              false => 4,
            };
            final cellWidth =
                (constraints.maxWidth - Spacing.d24 * (columns - 1)) / columns;
            return Wrap(
              spacing: Spacing.d24,
              runSpacing: Spacing.d24,
              children: [
                for (final entry in _types)
                  SizedBox(
                    width: cellWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d6,
                      children: [
                        Text(
                          entry.type.id,
                          softWrap: false,
                          style: theme.typography.face(
                            KevinSansFace.type,
                            cssSize: 11,
                            color: theme.colors.pencilText,
                          ),
                        ),
                        Annotate(
                          type: entry.type,
                          color: switch (entry.type) {
                            AnnotateType.highlight => AnnotateColor.yellow,
                            AnnotateType.strikeThrough ||
                            AnnotateType.crossedOff ||
                            AnnotateType.circle => AnnotateColor.red,
                            _ => AnnotateColor.blue,
                          },
                          child: Text(
                            entry.word,
                            style: theme.typography.interface(cssSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
