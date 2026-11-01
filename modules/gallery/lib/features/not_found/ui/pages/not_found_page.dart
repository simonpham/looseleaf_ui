import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// Shown for a path nothing matches, or a component or block not drawn yet.
///
/// Mirrors `NotFoundPage` in upstream `src/docs/pages/NotFoundPage.tsx`.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.what = 'page', required this.missing});

  /// What was looked for: page, component, block or topic.
  final String what;
  final String missing;

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    return DocPage(
      kicker: '404',
      title: 'Nothing on this page',
      description:
          'There is no $what called "$missing" in this notebook (yet).',
      children: [
        Empty(
          children: [
            const EmptyHeader(
              children: [
                EmptyMedia(pose: 'oops'),
                EmptyTitle(child: Text('Torn out, or never written')),
                EmptyDescription(
                  child: Text(
                    'Try the components index, or start from the top.',
                  ),
                ),
              ],
            ),
            EmptyContent(
              children: [
                Wrap(
                  spacing: Spacing.d12,
                  runSpacing: Spacing.d12,
                  alignment: WrapAlignment.center,
                  children: [
                    Button(
                      onPressed: () => navigation.go(const ComponentsRoute()),
                      child: const Text('Browse components'),
                    ),
                    Button(
                      variant: ButtonVariant.outline,
                      onPressed: () => navigation.go(const HomeRoute()),
                      child: const Text('Go home'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
