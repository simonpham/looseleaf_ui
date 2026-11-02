import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BreadcrumbDefaultExample extends StatelessWidget {
  const BreadcrumbDefaultExample({super.key});

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
            BreadcrumbLink(onPressed: () {}, child: const Text('Components')),
          ],
        ),
        const BreadcrumbSeparator(),
        const BreadcrumbItem(
          children: [
            BreadcrumbPage(seed: 'default', child: Text('Breadcrumb')),
          ],
        ),
      ],
    ),
  );
}
