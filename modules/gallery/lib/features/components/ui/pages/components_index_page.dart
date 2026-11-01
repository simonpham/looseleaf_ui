import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/components/ui/frames/frames.dart';
import 'package:gallery/features/components/view_models/view_models.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

/// Every ported component as a gallery of live thumbnails, by category.
///
/// Mirrors `ComponentsIndexPage` in upstream `src/docs/pages/ComponentsIndexPage.tsx`.
class ComponentsIndexPage extends StatefulWidget {
  const ComponentsIndexPage({super.key});

  @override
  State<ComponentsIndexPage> createState() => _ComponentsIndexPageState();
}

class _ComponentsIndexPageState extends State<ComponentsIndexPage> {
  final ComponentFilterViewModel _filter = ComponentFilterViewModel();

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: _filter,
    child: DocPage(
      kicker: 'The library',
      title: 'Components',
      description:
          '${ComponentCatalog.components.length} of ${ComponentCatalog.upstreamCount} components drawn so far, each a real, accessible widget with the parts and props of shadcn/ui.',
      children: const [ComponentFilterFrame()],
    ),
  );
}
