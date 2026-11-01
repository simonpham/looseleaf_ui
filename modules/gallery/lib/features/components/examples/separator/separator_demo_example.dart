import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SeparatorDemoExample extends StatelessWidget {
  const SeparatorDemoExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.interface(cssSize: 14);
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Radix Primitives',
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              cssLineHeight: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Spacing.d4),
          Text(
            'An open-source UI component library.',
            style: small.copyWith(color: theme.colors.inkMuted),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.d16),
            child: Separator(),
          ),
          SizedBox(
            height: Spacing.d20,
            child: DefaultTextStyle.merge(
              style: small,
              child: const Row(
                spacing: Spacing.d16,
                children: [
                  Text('Blog'),
                  Separator(orientation: SeparatorOrientation.vertical),
                  Text('Docs'),
                  Separator(orientation: SeparatorOrientation.vertical),
                  Text('Source'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
