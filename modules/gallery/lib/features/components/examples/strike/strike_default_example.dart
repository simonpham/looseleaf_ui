import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StrikeDefaultExample extends StatelessWidget {
  const StrikeDefaultExample({super.key});

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
              TextSpan(text: 'We meet on '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Strike(child: Text('Thursday at nine')),
              ),
              TextSpan(
                text: ' Friday at ten, in the room with the good chairs.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
