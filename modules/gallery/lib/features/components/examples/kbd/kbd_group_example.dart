import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class KbdGroupExample extends StatelessWidget {
  const KbdGroupExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Text.rich(
      TextSpan(
        style: theme.typography.interface(
          cssSize: 14,
          color: theme.colors.inkMuted,
        ),
        children: const [
          TextSpan(text: 'Use '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: KbdGroup(
              children: [
                Kbd(child: Text('Ctrl + B')),
                Kbd(child: Text('Ctrl + K')),
              ],
            ),
          ),
          TextSpan(text: ' to open the command palette'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
