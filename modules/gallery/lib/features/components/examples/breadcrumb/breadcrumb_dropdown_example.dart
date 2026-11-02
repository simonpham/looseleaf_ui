import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BreadcrumbDropdownExample extends StatelessWidget {
  const BreadcrumbDropdownExample({super.key});

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
                width: Spacing.d96 * 2,
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.d4,
                    children: [
                      Text('Components'),
                      InkIcon('chevron-down', size: Spacing.d14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const BreadcrumbSeparator(),
        const BreadcrumbItem(
          children: [
            BreadcrumbPage(seed: 'dropdown', child: Text('Breadcrumb')),
          ],
        ),
      ],
    ),
  );
}
