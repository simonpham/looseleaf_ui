import 'package:flutter/widgets.dart';
import 'package:gallery/features/foundations/docs/foundation_topics.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:provider/provider.dart';

/// Every foundations topic as a tile.
///
/// Mirrors `FoundationsPage` (the index) in upstream `src/docs/pages/FoundationsPage.tsx`.
class FoundationsIndexPage extends StatelessWidget {
  const FoundationsIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    return DocPage(
      kicker: 'Foundations',
      title: 'Foundations',
      description: 'The ideas underneath: ink, paper, motion, density.',
      children: [
        TileGrid(
          children: [
            for (final topic in foundationTopics)
              DocTile(
                title: topic.title,
                description: topic.summary,
                onPressed: () => navigation.go(FoundationsRoute(topic.slug)),
              ),
          ],
        ),
      ],
    );
  }
}
