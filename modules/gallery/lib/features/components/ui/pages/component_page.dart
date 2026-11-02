import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/components/models/models.dart';
import 'package:gallery/features/components/ui/widgets/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// A component's page: the hero example, installation, every other
/// example, the API reference, accessibility notes and related components.
///
/// Mirrors `ComponentPage` in upstream `src/docs/pages/ComponentPage.tsx`.
class ComponentPage extends StatelessWidget {
  const ComponentPage({super.key, required this.doc});

  final ComponentDoc doc;

  static const String install =
      "dependencies:\n  looseleaf_ui: ^0.1.0\n\n// in Dart\nimport 'package:looseleaf_ui/looseleaf_ui.dart';";

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    final examples = ComponentCatalog.examplesOf(doc.slug);
    final (previous, next) = ComponentCatalog.neighbours(doc.slug);
    final related = [
      for (final slug in doc.related)
        if (slug != doc.slug) slug,
    ];
    PagerLink? linkTo(ComponentDoc? target) => switch (target) {
      null => null,
      final page => (
        title: page.title,
        onPressed: () => navigation.go(ComponentsRoute(page.slug)),
      ),
    };
    return DocPage(
      kicker: doc.category.label,
      title: doc.title,
      description: doc.description,
      meta: [
        DocChip(
          doc.status.label,
          tone: switch (doc.status) {
            ComponentStatus.stable => DocChipTone.stable,
            ComponentStatus.isNew => DocChipTone.fresh,
            ComponentStatus.experimental => DocChipTone.experimental,
          },
        ),
        if (doc.upstream case final name?)
          DocChip('extends shadcn/ui $name', tone: DocChipTone.outline),
        DocChip(switch (examples.length) {
          1 => '1 example',
          final count => '$count examples',
        }, tone: DocChipTone.outline),
      ],
      footer: DocPager(previous: linkTo(previous), next: linkTo(next)),
      children: [
        if (examples.firstOrNull case final hero?)
          DocSection(
            title: 'Preview',
            children: [ExampleViewer(example: hero)],
          ),
        const DocSection(
          title: 'Installation',
          children: [DocCodeBlock(code: install, title: 'pubspec.yaml')],
        ),
        if (examples.length > 1)
          DocSection(
            title: 'Examples',
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d48,
                children: [
                  for (final example in examples.skip(1))
                    ExampleViewer(example: example),
                ],
              ),
            ],
          ),
        DocSection(
          title: 'API reference',
          description:
              "The parts and props of upstream Looseleaf. The Flutter widgets keep the parts and their names; callbacks and values take Flutter's names (onClick is onPressed, checked is value).",
          children: [
            switch (doc.parts) {
              [] => const DocHint(
                'This component has no parts documented yet.',
              ),
              final parts => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d40,
                children: [for (final part in parts) ApiPart(part: part)],
              ),
            },
          ],
        ),
        if (doc.a11y.isNotEmpty)
          DocSection(
            title: 'Accessibility',
            children: [
              TypographyList(
                children: [for (final line in doc.a11y) Text(line)],
              ),
            ],
          ),
        if (related.isNotEmpty)
          DocSection(
            title: 'Related',
            children: [
              Wrap(
                spacing: Spacing.d20,
                runSpacing: Spacing.d8,
                children: [
                  for (final slug in related)
                    switch (ComponentCatalog.bySlug(slug)) {
                      final target? => DocLink(
                        target.title,
                        onPressed: () => navigation.go(ComponentsRoute(slug)),
                      ),
                      null => DocHint(
                        '${ComponentCatalog.upstreamDoc(slug)?.title ?? slug} (not ported yet)',
                      ),
                    },
                ],
              ),
            ],
          ),
      ],
    );
  }
}
