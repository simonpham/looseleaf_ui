import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScribbleDefaultExample extends StatelessWidget {
  const ScribbleDefaultExample({super.key});

  static const _maxWidth = Spacing.d448;

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
        child: const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Dear '),
              _Scribbled(Scribble(child: Text('Mr. Whitcombe'))),
              TextSpan(
                text: ' Sam, thank you for the tomatoes; they were ',
              ),
              _Scribbled(
                Scribble(weight: MarkWeight.fine, child: Text('acceptable')),
              ),
              TextSpan(text: ' wonderful.'),
            ],
          ),
        ),
      ),
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
