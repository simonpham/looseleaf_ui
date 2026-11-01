import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/components/ui/widgets/widgets.dart';
import 'package:gallery/features/components/view_models/view_models.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// The components index body: the filter, then either its matches or every
/// category with its tiles.
///
/// Mirrors upstream `src/docs/content/components-gallery.tsx`.
class ComponentFilterFrame extends StatelessWidget {
  const ComponentFilterFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final filter = context.read<ComponentFilterViewModel>();
    final navigation = context.read<NavigationViewModel>();
    final needle = context.select<ComponentFilterViewModel, String>(
      (model) => model.needle,
    );
    final matches = context.select<ComponentFilterViewModel, int>(
      (model) => model.matches.length,
    );
    void open(String slug) => navigation.go(ComponentsRoute(slug));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d40,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Input(
              placeholder: 'Filter components...',
              semanticLabel: 'Filter components',
              onChanged: filter.setQuery,
            ),
          ),
        ),
        if (needle.isNotEmpty) ...[
          DocHint(switch (matches) {
            0 => 'No component matches "$needle".',
            1 => '1 match',
            final count => '$count matches',
          }),
          ComponentGrid(docs: filter.matches, onOpen: open),
        ],
        if (needle.isEmpty)
          for (final (category, docs) in ComponentCatalog.groups)
            DocSection(
              title: category.label,
              trailing: DocChip('${docs.length}', tone: DocChipTone.count),
              children: [ComponentGrid(docs: docs, onOpen: open)],
            ),
      ],
    );
  }
}
