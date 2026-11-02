import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = Spacing.d512;

WidgetSpan _inline(Widget child) => WidgetSpan(
  alignment: PlaceholderAlignment.baseline,
  baseline: TextBaseline.alphabetic,
  child: child,
);

class AnnotateReviewExample extends StatefulWidget {
  const AnnotateReviewExample({super.key});

  @override
  State<AnnotateReviewExample> createState() => _AnnotateReviewExampleState();
}

class _AnnotateReviewExampleState extends State<AnnotateReviewExample> {
  bool _review = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Semantics(
            toggled: _review,
            child: Button(
              size: ButtonSize.sm,
              variant: switch (_review) {
                true => ButtonVariant.primary,
                false => ButtonVariant.outline,
              },
              onPressed: () => setState(() => _review = !_review),
              child: Text(switch (_review) {
                true => 'Clear the marks',
                false => 'Review the draft',
              }),
            ),
          ),
          Paper(
            padding: const EdgeInsets.all(Spacing.d28),
            child: Text.rich(
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 17,
                cssLineHeight: 1.9,
              ),
              TextSpan(
                children: [
                  const TextSpan(text: 'The garden was '),
                  _inline(
                    Annotate(
                      type: AnnotateType.scribble,
                      weight: MarkWeight.fine,
                      show: _review,
                      animate: true,
                      child: const Text('very extremely'),
                    ),
                  ),
                  const TextSpan(
                    text: ' overgrown, and the gate, which had been ',
                  ),
                  _inline(
                    Annotate(
                      type: AnnotateType.crossedOff,
                      show: _review,
                      animate: true,
                      delay: const Duration(milliseconds: 500),
                      child: const Text('painted green'),
                    ),
                  ),
                  const TextSpan(text: ' left open for years, '),
                  _inline(
                    Annotate(
                      type: AnnotateType.brackets,
                      color: AnnotateColor.blue,
                      show: _review,
                      animate: true,
                      delay: const Duration(milliseconds: 1000),
                      child: const Text('no longer closed properly at all'),
                    ),
                  ),
                  const TextSpan(text: ' closed.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
