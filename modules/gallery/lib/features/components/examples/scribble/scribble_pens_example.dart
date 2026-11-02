import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScribblePensExample extends StatelessWidget {
  const ScribblePensExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 17,
        cssLineHeight: 1.55,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d12,
        children: [
          _PenRow(
            pen: 'Ink brush',
            line: [
              TextSpan(text: 'Meet on '),
              _Scribbled(Scribble(child: Text('Tuesday'))),
              TextSpan(text: ' Thursday.'),
            ],
          ),
          _PenRow(
            pen: 'Fine liner',
            line: [
              TextSpan(text: 'The password is '),
              _Scribbled(
                Scribble(weight: MarkWeight.fine, child: Text('hunter2')),
              ),
              TextSpan(text: ', still readable.'),
            ],
          ),
          _PenRow(
            pen: 'Red felt',
            line: [
              TextSpan(text: 'Total '),
              _Scribbled(Scribble(tone: MarkPen.red, child: Text('14.10'))),
              TextSpan(text: ' 12.00.'),
            ],
          ),
          _PenRow(
            pen: 'Blue felt',
            line: [
              TextSpan(text: 'Call '),
              _Scribbled(Scribble(tone: MarkPen.blue, child: Text('Ada'))),
              TextSpan(text: ' Jo about the tomatoes.'),
            ],
          ),
          _PenRow(
            pen: 'Soft pencil',
            line: [
              TextSpan(text: 'Pick up '),
              _Scribbled(Scribble(tone: MarkPen.pencil, child: Text('milk'))),
              TextSpan(text: ' oat milk.'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PenRow extends StatelessWidget {
  const _PenRow({required this.pen, required this.line});

  static const _penWidth = 104.0;

  final String pen;
  final List<InlineSpan> line;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      spacing: Spacing.d16,
      children: [
        SizedBox(
          width: _penWidth,
          child: Text(
            pen,
            style: theme.typography.stamp(
              cssSize: 12,
              color: theme.colors.inkMuted,
            ),
          ),
        ),
        Expanded(child: Text.rich(TextSpan(children: line))),
      ],
    );
  }
}

class _Scribbled extends WidgetSpan {
  const _Scribbled(Scribble scribble)
    : super(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: scribble,
      );
}
