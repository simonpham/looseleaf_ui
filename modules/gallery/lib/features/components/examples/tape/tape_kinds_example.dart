import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TapeKindsExample extends StatelessWidget {
  const TapeKindsExample({super.key});

  static const _wide = 640.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth >= _wide) {
          true => 4,
          false => 2,
        };
        final width =
            (constraints.maxWidth - Spacing.d32 - Spacing.d32 * (columns - 1)) /
                columns -
            Spacing.d1;
        return Padding(
          padding: const EdgeInsets.all(Spacing.d16),
          child: Wrap(
            spacing: Spacing.d32,
            runSpacing: Spacing.d24,
            children: [
              for (final kind in TapeKind.values)
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d8,
                    children: [
                      Tape(kind: kind, length: 110, height: 26, seed: kind.id),
                      Text(
                        kind.id,
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
