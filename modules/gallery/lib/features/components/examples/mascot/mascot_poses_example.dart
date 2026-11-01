import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MascotPosesExample extends StatelessWidget {
  const MascotPosesExample({super.key});

  static const _poses = ['idle', 'wave', 'think', 'sleep'];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      spacing: Spacing.d32,
      runSpacing: Spacing.d32,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final pose in _poses)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d4,
            children: [
              Mascot(pose: pose),
              Text(
                pose,
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.pencilText,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
