import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CircledDefaultExample extends StatelessWidget {
  const CircledDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Text.rich(
        style: theme.typography.interface(cssSize: 17).copyWith(height: 1.55),
        const TextSpan(
          children: [
            TextSpan(text: 'We agreed to ship the first draft before '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.d8),
                child: Circled(tone: MarkPen.red, child: Text('Friday')),
              ),
            ),
            TextSpan(text: ', so please reply today with the numbers.'),
          ],
        ),
      ),
    );
  }
}
