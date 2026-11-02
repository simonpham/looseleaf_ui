import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StrikeKindsExample extends StatelessWidget {
  const StrikeKindsExample({super.key});

  static const _maxWidth = Spacing.d512;

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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  _Struck(Strike(child: Text('single'))),
                  TextSpan(text: ', '),
                  _Struck(
                    Strike(kind: StrikeKind.double, child: Text('double')),
                  ),
                  TextSpan(text: ', and '),
                  _Struck(
                    Strike(
                      kind: StrikeKind.cross,
                      child: Text('a cross-out over the whole phrase'),
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  _Struck(Strike(tone: MarkPen.ink, child: Text('ink felt'))),
                  TextSpan(text: ', '),
                  _Struck(Strike(tone: MarkPen.blue, child: Text('blue felt'))),
                  TextSpan(text: ', '),
                  _Struck(
                    Strike(
                      weight: MarkWeight.brush,
                      child: Text('a brush pen'),
                    ),
                  ),
                  TextSpan(text: ', '),
                  _Struck(
                    Strike(
                      weight: MarkWeight.fine,
                      child: Text('a fine-liner'),
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Struck extends WidgetSpan {
  const _Struck(Strike strike)
    : super(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: strike,
      );
}
