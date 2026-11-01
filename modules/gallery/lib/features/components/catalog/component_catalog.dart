import 'package:gallery/features/components/catalog/component_examples.dart';
import 'package:gallery/features/components/docs/all_component_docs.dart';
import 'package:gallery/features/components/models/models.dart';

/// The ported components grouped like upstream's catalog
/// (`src/docs/core/catalog.ts`): by category, then by title.
abstract final class ComponentCatalog {
  /// Every ported component, in nav order.
  static final List<ComponentDoc> components = [
    for (final group in groups) ...group.$2,
  ];

  /// The ported components per category, empty categories left out.
  static final List<(ComponentCategory, List<ComponentDoc>)> groups = [
    for (final category in ComponentCategory.values)
      if (_inCategory(category) case final docs when docs.isNotEmpty)
        (category, docs),
  ];

  /// Every upstream component, ported or not.
  static int get upstreamCount => allComponentDocs.length;

  /// The ported component [slug], or null.
  static ComponentDoc? bySlug(String slug) {
    if (!componentExamples.containsKey(slug)) return null;
    return allComponentDocs[slug];
  }

  /// Upstream's doc for [slug], ported or not.
  static ComponentDoc? upstreamDoc(String slug) => allComponentDocs[slug];

  static List<GalleryExample> examplesOf(String slug) =>
      componentExamples[slug] ?? const [];

  /// The components before and after [slug] in nav order.
  static (ComponentDoc?, ComponentDoc?) neighbours(String slug) {
    final index = components.indexWhere((doc) => doc.slug == slug);
    if (index < 0) return (null, null);
    final previous = switch (index) {
      0 => null,
      _ => components[index - 1],
    };
    return (previous, components.elementAtOrNull(index + 1));
  }

  static List<ComponentDoc> _inCategory(ComponentCategory category) => [
    for (final slug in componentExamples.keys)
      if (allComponentDocs[slug] case final doc? when doc.category == category)
        doc,
  ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
}
