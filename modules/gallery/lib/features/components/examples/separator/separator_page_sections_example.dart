import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SeparatorPageSectionsExample extends StatelessWidget {
  const SeparatorPageSectionsExample({super.key});

  static const _maxWidth = Spacing.d448;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d20,
        children: [
          const _Section(
            title: 'Saturday market',
            body:
                'Tomatoes that were still warm, a bag of plums, and a man selling only string.',
          ),
          Semantics(
            label: 'End of the market notes',
            child: const Separator(
              variant: SeparatorVariant.torn,
              decorative: false,
            ),
          ),
          const _Section(
            title: 'Sunday, indoors',
            body:
                'Rain all morning. Mended the blue coat with orange thread and no regrets.',
          ),
          const Separator(variant: SeparatorVariant.stitched),
          const _Section(title: 'Monday', body: 'Back to the desk. Fold here.'),
          const Separator(variant: SeparatorVariant.tape),
          const _Section(
            title: 'Tuesday',
            body: 'Nothing happened. Wrote it all down anyway.',
          ),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d4,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.typography.face(
              KevinSansFace.script,
              cssSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          body,
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 15,
            cssLineHeight: 1.375,
          ),
        ),
      ],
    );
  }
}
