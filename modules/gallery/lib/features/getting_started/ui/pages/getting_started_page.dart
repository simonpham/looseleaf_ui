import 'package:flutter/widgets.dart';
import 'package:gallery/features/getting_started/models/models.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// Add the package, wrap the app in [LooseleafTheme], use a widget.
///
/// Mirrors `GettingStartedPage` in upstream `src/docs/pages/GettingStartedPage.tsx`.
class GettingStartedPage extends StatelessWidget {
  const GettingStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    final theme = LooseleafTheme.of(context);
    return DocPage(
      kicker: 'Start here',
      title: 'Getting started',
      description: 'Add one package, wrap your app in LooseleafTheme and use the widgets like any other. It takes about a minute.',
      children: [
        for (final step in guideSteps)
          DocSection(
            title: step.title,
            description: step.description,
            children: [
              for (final paragraph in step.paragraphs)
                Text(paragraph, style: TextStyle(color: theme.colors.ink)),
              for (final block in step.code)
                DocCodeBlock(code: block.code, title: block.title),
            ],
          ),
        DocSection(
          title: 'Next steps',
          children: [
            Wrap(
              spacing: Spacing.d24,
              runSpacing: Spacing.d8,
              children: [
                DocLink(
                  'Browse the components',
                  onPressed: () => navigation.go(const ComponentsRoute()),
                ),
                DocLink(
                  'Read the foundations',
                  onPressed: () => navigation.go(const FoundationsRoute()),
                ),
                DocLink(
                  'Look at the blocks',
                  onPressed: () => navigation.go(const BlocksRoute()),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
