import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BreadcrumbResponsiveExample extends StatelessWidget {
  const BreadcrumbResponsiveExample({super.key});

  static const _items = [
    (label: 'Home', linked: true),
    (label: 'Documentation', linked: true),
    (label: 'Build your application', linked: true),
    (label: 'Data fetching', linked: true),
    (label: 'Caching and revalidating', linked: false),
  ];
  static const _itemsToDisplay = 3;
  static const double _desktopFrom = 768;
  static const double _narrowCrumb = Spacing.d80;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= _desktopFrom;
    final folded = _items.sublist(1, _items.length - _itemsToDisplay + 1);
    final tail = _items.sublist(_items.length - _itemsToDisplay + 1);
    return Breadcrumb(
      child: BreadcrumbList(
        children: [
          BreadcrumbItem(
            children: [
              BreadcrumbLink(onPressed: () {}, child: Text(_items.first.label)),
            ],
          ),
          const BreadcrumbSeparator(),
          if (_items.length > _itemsToDisplay) ...[
            BreadcrumbItem(
              children: [
                switch (isDesktop) {
                  true => _FoldMenu(
                    labels: [for (final item in folded) item.label],
                  ),
                  false => _FoldDrawer(
                    labels: [for (final item in folded) item.label],
                  ),
                },
              ],
            ),
            const BreadcrumbSeparator(),
          ],
          for (final (i, item) in tail.indexed) ...[
            BreadcrumbItem(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: switch (isDesktop) {
                      true => double.infinity,
                      false => _narrowCrumb,
                    },
                  ),
                  child: switch (item.linked) {
                    true => BreadcrumbLink(
                      onPressed: () {},
                      child: Text(item.label, overflow: TextOverflow.ellipsis),
                    ),
                    false => BreadcrumbPage(
                      seed: 'responsive',
                      child: Text(item.label, overflow: TextOverflow.ellipsis),
                    ),
                  },
                ),
              ],
            ),
            if (i < tail.length - 1) const BreadcrumbSeparator(),
          ],
        ],
      ),
    );
  }
}

class _FoldMenu extends StatelessWidget {
  const _FoldMenu({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) => DropdownMenu(
    content: DropdownMenuContent(
      align: OverlayAlign.start,
      width: Spacing.d112 * 2,
      children: [
        for (final label in labels) DropdownMenuItem(child: Text(label)),
      ],
    ),
    child: DropdownMenuTrigger.builder(
      builder: (context, menu) => BreadcrumbLink(
        onPressed: menu.toggle,
        forcedStates: {if (menu.open) InkState.hovered},
        child: const BreadcrumbEllipsis(semanticLabel: 'Toggle menu'),
      ),
    ),
  );
}

class _FoldDrawer extends StatelessWidget {
  const _FoldDrawer({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) => Drawer(
    content: DrawerContent(
      seed: 'crumbs',
      children: [
        const DrawerHeader(
          children: [
            DrawerTitle(Text('Navigate to')),
            DrawerDescription(Text('Select a page to navigate to.')),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d4,
            children: [
              for (final label in labels)
                BreadcrumbLink(onPressed: () {}, child: Text(label)),
            ],
          ),
        ),
        DrawerFooter(
          children: [
            DrawerClose(
              builder: (context, close) => Button(
                variant: ButtonVariant.outline,
                onPressed: close,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ],
    ),
    child: DrawerTrigger.builder(
      builder: (context, drawer) => BreadcrumbLink(
        onPressed: drawer.toggle,
        child: const BreadcrumbEllipsis(semanticLabel: 'Toggle menu'),
      ),
    ),
  );
}
