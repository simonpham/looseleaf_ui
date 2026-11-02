import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = Spacing.d512;

const _highlights = [
  AnnotateColor.yellow,
  AnnotateColor.pink,
  AnnotateColor.green,
  AnnotateColor.blue,
  AnnotateColor.orange,
  AnnotateColor.lilac,
  AnnotateColor.teal,
];

const _pens = [
  AnnotateColor.ink,
  AnnotateColor.blue,
  AnnotateColor.red,
  AnnotateColor.green,
  AnnotateColor.pencil,
];

class AnnotateColoursExample extends StatelessWidget {
  const AnnotateColoursExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 17,
          cssLineHeight: 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d20,
          children: [
            Wrap(
              spacing: Spacing.d20,
              runSpacing: Spacing.d8,
              children: [
                for (final color in _highlights)
                  Annotate(
                    type: AnnotateType.highlight,
                    color: color,
                    child: Text(color.name),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: Spacing.d4),
              child: Wrap(
                spacing: Spacing.d24,
                runSpacing: Spacing.d12,
                children: [
                  for (final color in _pens)
                    Annotate(
                      type: AnnotateType.circle,
                      color: color,
                      child: Text(color.name),
                    ),
                  const Annotate(
                    type: AnnotateType.circle,
                    color: AnnotateColor.red,
                    weight: MarkWeight.brush,
                    child: Text('brush'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
