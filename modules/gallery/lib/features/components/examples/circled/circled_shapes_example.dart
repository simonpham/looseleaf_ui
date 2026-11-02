import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CircledShapesExample extends StatelessWidget {
  const CircledShapesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d128 * 4),
      child: DefaultTextStyle.merge(
        style: theme.typography.interface(cssSize: 17).copyWith(height: 2),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.d8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'A '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Spacing.d6),
                        child: Circled(child: Text('circle')),
                      ),
                    ),
                    TextSpan(text: ', a '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Spacing.d6),
                        child: Circled(
                          shape: CircledShape.box,
                          child: Text('box'),
                        ),
                      ),
                    ),
                    TextSpan(text: ', and '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Spacing.d8),
                        child: Circled(
                          shape: CircledShape.brackets,
                          child: Text('a pair of brackets'),
                        ),
                      ),
                    ),
                    TextSpan(text: ' around a phrase.'),
                  ],
                ),
              ),
              Wrap(
                spacing: Spacing.d24,
                children: [
                  Circled(tone: MarkPen.blue, child: Text('blue felt')),
                  Circled(tone: MarkPen.red, child: Text('red felt')),
                  Circled(tone: MarkPen.pencil, child: Text('pencil')),
                  Circled(
                    tone: MarkPen.red,
                    weight: MarkWeight.brush,
                    child: Text('brush pen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
