import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class KbdKeysAndGroupsExample extends StatelessWidget {
  const KbdKeysAndGroupsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final plus = Text(
      '+',
      style: theme.typography.interface(
        cssSize: 14,
        color: theme.colors.inkMuted,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d20,
      children: [
        Text.rich(
          TextSpan(
            style: theme.typography.interface(cssSize: 16),
            children: const [
              TextSpan(text: 'Press '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Kbd(child: Text('Esc')),
              ),
              TextSpan(text: ' to close, '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Kbd(child: Text('Tab')),
              ),
              TextSpan(text: ' to move on, or '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Kbd(child: Text('Enter')),
              ),
              TextSpan(text: ' to go.'),
            ],
          ),
        ),
        Wrap(
          spacing: Spacing.d32,
          runSpacing: Spacing.d12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            KbdGroup(
              children: [
                const Kbd(child: Text('Ctrl')),
                plus,
                const Kbd(child: Text('K')),
              ],
            ),
            KbdGroup(
              children: [
                const Kbd(child: Text('Ctrl')),
                plus,
                const Kbd(child: Text('Shift')),
                plus,
                const Kbd(child: Text('P')),
              ],
            ),
            KbdGroup(
              children: [
                const Kbd(child: Text('Alt')),
                plus,
                const Kbd(child: Text('F4')),
              ],
            ),
            const Kbd(child: Text('Space')),
          ],
        ),
      ],
    );
  }
}
