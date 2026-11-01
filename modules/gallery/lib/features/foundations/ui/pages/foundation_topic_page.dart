import 'package:flutter/widgets.dart';
import 'package:gallery/features/foundations/docs/foundation_topics.dart';
import 'package:gallery/features/foundations/models/models.dart';
import 'package:gallery/features/foundations/ui/widgets/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// One foundations topic: its facts, a live demo and what to read next.
///
/// Mirrors `FoundationsPage` (a topic) in upstream `src/docs/pages/FoundationsPage.tsx`.
class FoundationTopicPage extends StatelessWidget {
  const FoundationTopicPage({super.key, required this.topic});

  final FoundationTopic topic;

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    final theme = LooseleafTheme.of(context);
    final index = foundationTopics.indexOf(topic);
    final previous = switch (index) {
      0 => null,
      _ => foundationTopics[index - 1],
    };
    final next = foundationTopics.elementAtOrNull(index + 1);
    PagerLink? linkTo(FoundationTopic? target) => switch (target) {
      null => null,
      final page => (
        title: page.title,
        onPressed: () => navigation.go(FoundationsRoute(page.slug)),
      ),
    };
    return DocPage(
      kicker: 'Foundations',
      title: topic.title,
      description: topic.summary,
      footer: DocPager(previous: linkTo(previous), next: linkTo(next)),
      children: [
        TypographyList(
          children: [for (final fact in topic.facts) Text(fact)],
        ),
        if (TopicDemo.has(topic))
          DocSection(
            title: 'On the page',
            children: [
              Paper(
                stock: StockName.dotGrid,
                tilt: false,
                shadow: PaperShadow.slip,
                seed: 'foundation:${topic.slug}',
                padding: const EdgeInsets.all(Spacing.d24),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: theme.colors.ink),
                  child: TopicDemo(topic: topic),
                ),
              ),
            ],
          ),
        if (topic.see.isNotEmpty)
          DocSection(
            title: 'See also',
            children: [
              Wrap(
                spacing: Spacing.d20,
                runSpacing: Spacing.d8,
                children: [
                  for (final see in topic.see)
                    DocLink(
                      see.label,
                      onPressed: () =>
                          navigation.go(FoundationsRoute(see.slug)),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
