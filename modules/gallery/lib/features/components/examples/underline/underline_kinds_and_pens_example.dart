import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = Spacing.d512;

WidgetSpan _mark(Underline underline) => WidgetSpan(
  alignment: PlaceholderAlignment.baseline,
  baseline: TextBaseline.alphabetic,
  child: underline,
);

class UnderlineKindsAndPensExample extends StatelessWidget {
  const UnderlineKindsAndPensExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 17,
          cssLineHeight: 1.55,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  _mark(const Underline(child: Text('single'))),
                  const TextSpan(text: ', '),
                  _mark(
                    const Underline(
                      kind: UnderlineMarkKind.double,
                      child: Text('double'),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  _mark(
                    const Underline(
                      kind: UnderlineMarkKind.wavy,
                      tone: MarkPen.blue,
                      child: Text('wavy'),
                    ),
                  ),
                  const TextSpan(text: ', and a '),
                  _mark(
                    const Underline(
                      kind: UnderlineMarkKind.scribble,
                      tone: MarkPen.red,
                      child: Text('quick scribble'),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  _mark(
                    const Underline(
                      tone: MarkPen.blue,
                      child: Text('blue felt'),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  _mark(
                    const Underline(tone: MarkPen.red, child: Text('red felt')),
                  ),
                  const TextSpan(text: ', '),
                  _mark(
                    const Underline(
                      tone: MarkPen.green,
                      child: Text('green felt'),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  _mark(
                    const Underline(
                      tone: MarkPen.pencil,
                      child: Text('soft pencil'),
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  _mark(
                    const Underline(
                      tone: MarkPen.marker,
                      child: Text('marker'),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  _mark(
                    const Underline(
                      weight: MarkWeight.fine,
                      child: Text('fine-liner'),
                    ),
                  ),
                  const TextSpan(text: ', '),
                  _mark(const Underline(child: Text('felt tip'))),
                  const TextSpan(text: ', '),
                  _mark(
                    const Underline(
                      weight: MarkWeight.brush,
                      tone: MarkPen.blue,
                      child: Text('brush pen'),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
