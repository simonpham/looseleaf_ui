import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

class UnderlineDefaultExample extends StatelessWidget {
  const UnderlineDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Text.rich(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 17,
          cssLineHeight: 1.55,
        ),
        const TextSpan(
          children: [
            TextSpan(text: 'Underline the parts you will need again, like '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Underline(child: Text('the date of the meeting')),
            ),
            TextSpan(text: ', and leave the rest for the next pass.'),
          ],
        ),
      ),
    );
  }
}
