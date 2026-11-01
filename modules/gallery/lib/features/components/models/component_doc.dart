import 'package:gallery/features/components/models/component_category.dart';
import 'package:gallery/features/components/models/component_status.dart';
import 'package:gallery/features/components/models/part_doc.dart';

/// A component's docs page data, upstream `ComponentDoc` (`src/docs/meta/<slug>.ts`).
class ComponentDoc {
  const ComponentDoc({
    required this.slug,
    required this.title,
    required this.category,
    required this.description,
    this.status = ComponentStatus.stable,
    this.upstream,
    this.parts = const [],
    this.a11y = const [],
    this.related = const [],
  });

  final String slug;
  final String title;
  final ComponentCategory category;
  final String description;
  final ComponentStatus status;

  /// The shadcn/ui component this one extends, if any.
  final String? upstream;
  final List<PartDoc> parts;

  /// Accessibility notes, one line each.
  final List<String> a11y;

  /// Slugs of related components.
  final List<String> related;
}
