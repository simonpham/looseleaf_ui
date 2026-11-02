import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BreadcrumbCollapsedExample extends StatelessWidget {
  const BreadcrumbCollapsedExample({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d24,
    children: [
      Breadcrumb(
        label: 'Breadcrumb, collapsed',
        child: BreadcrumbList(
          children: [
            BreadcrumbItem(
              children: [
                BreadcrumbLink(onPressed: () {}, child: const Text('Home')),
              ],
            ),
            const BreadcrumbSeparator(),
            const BreadcrumbItem(
              children: [ExcludeSemantics(child: BreadcrumbEllipsis())],
            ),
            const BreadcrumbSeparator(),
            BreadcrumbItem(
              children: [
                BreadcrumbLink(
                  onPressed: () {},
                  child: const Text('Components'),
                ),
              ],
            ),
            const BreadcrumbSeparator(),
            const BreadcrumbItem(
              children: [
                BreadcrumbPage(seed: 'collapsed', child: Text('Breadcrumb')),
              ],
            ),
          ],
        ),
      ),
      Breadcrumb(
        label: 'Breadcrumb, collapsed with a link',
        child: BreadcrumbList(
          children: [
            BreadcrumbItem(
              children: [
                BreadcrumbLink(onPressed: () {}, child: const Text('Home')),
              ],
            ),
            const BreadcrumbSeparator(),
            BreadcrumbItem(
              children: [
                BreadcrumbLink(
                  onPressed: () {},
                  child: const BreadcrumbEllipsis(
                    semanticLabel: 'Show the full path',
                  ),
                ),
              ],
            ),
            const BreadcrumbSeparator(),
            const BreadcrumbItem(
              children: [
                BreadcrumbPage(
                  seed: 'collapsed-link',
                  child: Text('Breadcrumb'),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
