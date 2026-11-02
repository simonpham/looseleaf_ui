import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SquiggleKindsExample extends StatelessWidget {
  const SquiggleKindsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d512),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          for (final (index, kind) in SquiggleKind.values.indexed)
            Row(
              spacing: Spacing.d12,
              children: [
                SizedBox(
                  width: Spacing.d80 + Spacing.d8,
                  child: Text(
                    kind.name,
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Squiggle(
                    kind: kind,
                    tone: switch (index.isOdd) {
                      true => MarkPen.blue,
                      false => MarkPen.ink,
                    },
                  ),
                ),
              ],
            ),
          SizedBox(
            height: Spacing.d112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d24,
              children: [
                for (final kind in SquiggleKind.values)
                  Squiggle(
                    kind: kind,
                    orientation: SquiggleOrientation.vertical,
                    tone: MarkPen.pencil,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
