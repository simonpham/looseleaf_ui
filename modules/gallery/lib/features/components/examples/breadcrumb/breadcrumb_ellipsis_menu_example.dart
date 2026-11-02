import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BreadcrumbEllipsisMenuExample extends StatelessWidget {
  const BreadcrumbEllipsisMenuExample({super.key});

  @override
  Widget build(BuildContext context) => Breadcrumb(
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
            DropdownMenu(
              content: const DropdownMenuContent(
                align: OverlayAlign.start,
                width: Spacing.d192,
                children: [
                  DropdownMenuItem(child: Text('Documentation')),
                  DropdownMenuItem(child: Text('Themes')),
                  DropdownMenuItem(child: Text('GitHub')),
                ],
              ),
              child: DropdownMenuTrigger.builder(
                builder: (context, menu) => BreadcrumbLink(
                  onPressed: menu.toggle,
                  forcedStates: {if (menu.open) InkState.hovered},
                  child: const BreadcrumbEllipsis(semanticLabel: 'Toggle menu'),
                ),
              ),
            ),
          ],
        ),
        const BreadcrumbSeparator(),
        BreadcrumbItem(
          children: [
            BreadcrumbLink(onPressed: () {}, child: const Text('Components')),
          ],
        ),
        const BreadcrumbSeparator(),
        const BreadcrumbItem(
          children: [BreadcrumbPage(seed: 'folded', child: Text('Breadcrumb'))],
        ),
      ],
    ),
  );
}
