import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A primary link in the top bar: bold ink-soft text that gets a
/// highlighter swipe on hover and on the current page.
class TopBarLink extends StatelessWidget {
  const TopBarLink({
    super.key,
    required this.label,
    required this.current,
    required this.onPressed,
  });

  final String label;
  final bool current;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DocPressable(
      onPressed: onPressed,
      selected: current,
      builder: (context, highlighted) {
        final lit = highlighted || current;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d12,
            vertical: Spacing.d6,
          ),
          child: Highlight(
            show: lit,
            seed: 'top:$label',
            child: Text(
              label,
              style: theme.typography.face(
                KevinSansFace.hand,
                fontWeight: FontWeight.w700,
                color: switch (lit) {
                  true => theme.colors.ink,
                  false => theme.colors.inkSoft,
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
