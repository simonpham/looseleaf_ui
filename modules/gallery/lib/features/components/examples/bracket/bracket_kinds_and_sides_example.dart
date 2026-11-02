import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `w-44`.
const _width = 176.0;

class BracketKindsAndSidesExample extends StatelessWidget {
  const BracketKindsAndSidesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 17,
        cssLineHeight: 1.6,
      ),
      child: const Wrap(
        spacing: Spacing.d24,
        runSpacing: Spacing.d24,
        children: [
          SizedBox(
            width: _width,
            child: Bracket(
              child: Text('Square: for quoting a stretch of a page.'),
            ),
          ),
          SizedBox(
            width: _width,
            child: Bracket(
              kind: BracketKind.curly,
              tone: MarkPen.blue,
              side: BracketSide.end,
              child: Text(
                'Curly: for lumping things together, from the end side.',
              ),
            ),
          ),
          SizedBox(
            width: _width,
            child: Bracket(
              kind: BracketKind.round,
              tone: MarkPen.red,
              child: Text('Round: for an aside.'),
            ),
          ),
          SizedBox(
            width: _width,
            child: Bracket(
              weight: MarkWeight.brush,
              side: BracketSide.end,
              child: Text('A brush pen makes it a statement.'),
            ),
          ),
        ],
      ),
    );
  }
}
