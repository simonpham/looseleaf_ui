import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-4xl`.
const _maxWidth = 896.0;

/// Below this width the margin notes hide (`max-md:hidden`).
const _notesShownFrom = 760.0;

enum _Mark {
  circle('Circle'),
  highlight('Highlight'),
  underline('Underline'),
  strike('Strike'),
  wavy('Wavy line'),
  notes('Margin notes');

  const _Mark(this.label);

  final String label;
}

WidgetSpan _inline(Widget child) => WidgetSpan(
  alignment: PlaceholderAlignment.baseline,
  baseline: TextBaseline.alphabetic,
  child: child,
);

class AnnotatePlaygroundExample extends StatefulWidget {
  const AnnotatePlaygroundExample({super.key});

  @override
  State<AnnotatePlaygroundExample> createState() =>
      _AnnotatePlaygroundExampleState();
}

class _AnnotatePlaygroundExampleState extends State<AnnotatePlaygroundExample> {
  final Set<_Mark> _on = _Mark.values.toSet();
  int _take = 0;

  void _toggle(_Mark mark) => setState(() {
    if (_on.remove(mark)) return;
    _on.add(mark);
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final pencil = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.pencilText,
    );
    final paragraph = Text.rich(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 17,
        cssLineHeight: 28 / 17,
      ),
      TextSpan(
        children: [
          const TextSpan(
            text: 'Most of what I remember from a book is in the ',
          ),
          _inline(
            Annotate(
              type: AnnotateType.circle,
              color: AnnotateColor.red,
              show: _on.contains(_Mark.circle),
              animate: true,
              child: const Text('margins'),
            ),
          ),
          const TextSpan(
            text:
                ': an arrow, a question mark, a small argument with a dead '
                'author. The good bits get ',
          ),
          _inline(
            Annotate(
              type: AnnotateType.highlight,
              show: _on.contains(_Mark.highlight),
              animate: true,
              delay: const Duration(milliseconds: 200),
              child: const Text('a swipe of yellow'),
            ),
          ),
          const TextSpan(
            text:
                ' so I can find them on the next read, and the parts I do '
                'not believe get a ',
          ),
          _inline(
            Annotate(
              type: AnnotateType.underline,
              color: AnnotateColor.red,
              show: _on.contains(_Mark.underline),
              animate: true,
              delay: const Duration(milliseconds: 300),
              child: const Text('red pencil'),
            ),
          ),
          const TextSpan(text: '. By the '),
          _inline(
            Annotate(
              type: AnnotateType.highlight,
              color: AnnotateColor.green,
              show: _on.contains(_Mark.highlight),
              animate: true,
              delay: const Duration(milliseconds: 250),
              child: const Text('third reading'),
            ),
          ),
          const TextSpan(text: ' the book is more mine than the '),
          _inline(
            Annotate(
              type: AnnotateType.strikeThrough,
              show: _on.contains(_Mark.strike),
              animate: true,
              child: const Text('writer’s'),
            ),
          ),
          const TextSpan(text: ', which is the '),
          _inline(
            Annotate(
              type: AnnotateType.underline,
              kind: UnderlineMarkKind.wavy,
              color: AnnotateColor.blue,
              show: _on.contains(_Mark.wavy),
              animate: true,
              delay: const Duration(milliseconds: 400),
              child: const Text('whole point of owning one'),
            ),
          ),
          _inline(const Asterisk(label: 'footnote')),
          const TextSpan(text: '.'),
        ],
      ),
    );
    final notesShown = _on.contains(_Mark.notes);
    final notes = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d32,
      children: [
        Callout(
          'ha, true',
          show: notesShown,
          animate: true,
          delay: const Duration(milliseconds: 500),
          curve: ArrowCurve.straight,
        ),
        Callout(
          'the best line',
          show: notesShown,
          animate: true,
          delay: const Duration(milliseconds: 600),
        ),
        Callout(
          'not sure about this...',
          show: notesShown,
          animate: true,
          delay: const Duration(milliseconds: 900),
          bend: ArrowBend.down,
        ),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Semantics(
            container: true,
            label: 'Annotations',
            child: Wrap(
              spacing: Spacing.d16,
              runSpacing: Spacing.d16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final mark in _Mark.values)
                  Semantics(
                    toggled: _on.contains(mark),
                    child: Button(
                      size: ButtonSize.sm,
                      variant: switch (_on.contains(mark)) {
                        true => ButtonVariant.primary,
                        false => ButtonVariant.outline,
                      },
                      onPressed: () => _toggle(mark),
                      child: Text(mark.label),
                    ),
                  ),
                Button(
                  size: ButtonSize.sm,
                  variant: ButtonVariant.ghost,
                  onPressed: () => setState(() => _take++),
                  child: const Text('Replay'),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final withNotes = constraints.maxWidth >= _notesShownFrom;
              return Paper(
                key: ValueKey(_take),
                rules: RuleName.ruled,
                seed: 'reader',
                padding: const EdgeInsets.fromLTRB(
                  Spacing.d56,
                  Spacing.d16,
                  Spacing.d24,
                  Spacing.d24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading notes / Tuesday',
                      style: theme.typography.face(
                        KevinSansFace.type,
                        cssSize: 11,
                        cssLineHeight: 28 / 11,
                        color: theme.colors.pencilText,
                      ),
                    ),
                    Text(
                      'On owning books',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 33.6,
                        cssLineHeight: 56 / 33.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d16,
                      children: [
                        Expanded(child: paragraph),
                        if (withNotes) notes,
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.d28),
                      child: Row(
                        spacing: Spacing.d12,
                        children: [
                          Text('times I have read it', style: pencil),
                          const Tally(count: 7, animate: true),
                        ],
                      ),
                    ),
                    Text('* the whole shelf, eventually', style: pencil),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
