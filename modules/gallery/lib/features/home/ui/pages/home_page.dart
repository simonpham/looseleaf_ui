import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/home/ui/frames/frames.dart';
import 'package:gallery/features/home/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// The front page, straight on the desk: the hero with its sign-in card,
/// a desk of live cards, why, how, the numbers and a footer.
///
/// Mirrors `Home` in upstream `src/docs/content/home.tsx`.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Upstream's `max-w-[72rem]`.
  static const double maxWidth = 1152;

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    final components = ComponentCatalog.components;
    final ownCount = components.where((doc) => doc.upstream == null).length;
    return HomeDeskFrame(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.only(
              top: Spacing.d28,
              bottom: Spacing.d64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHero(
                  componentCount: components.length,
                  onGetStarted: () =>
                      navigation.go(const GettingStartedRoute()),
                  onBrowse: () => navigation.go(const ComponentsRoute()),
                ),
                const LiveDesk(),
                HomeWhy(ownCount: ownCount),
                HomeHow(
                  onGuide: () => navigation.go(const GettingStartedRoute()),
                ),
                HomeStats(
                  componentCount: components.length,
                  categoryCount: ComponentCatalog.groups.length,
                ),
                HomeFooter(
                  links: [
                    (
                      'Get started',
                      () => navigation.go(const GettingStartedRoute()),
                    ),
                    (
                      'Components',
                      () => navigation.go(const ComponentsRoute()),
                    ),
                    ('Blocks', () => navigation.go(const BlocksRoute())),
                    (
                      'Foundations',
                      () => navigation.go(const FoundationsRoute()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
