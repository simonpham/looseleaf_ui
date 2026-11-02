import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BreadcrumbFilePathExample extends StatefulWidget {
  const BreadcrumbFilePathExample({super.key});

  @override
  State<BreadcrumbFilePathExample> createState() =>
      _BreadcrumbFilePathExampleState();
}

class _BreadcrumbFilePathExampleState extends State<BreadcrumbFilePathExample> {
  static const _tree = {
    'Notebooks': ['Field notes', 'Garden', 'Recipes'],
    'Field notes': ['2026', '2025'],
    '2026': ['March', 'April'],
    'March': ['Week 1', 'Week 2'],
    'Garden': ['Beds', 'Seeds'],
    'Recipes': ['Soups', 'Bread'],
  };

  List<String> _path = const ['Notebooks', 'Field notes', '2026', 'March'];

  void _goTo(int depth) => setState(() => _path = _path.sublist(0, depth + 1));

  Widget _crumb(int at, {required bool last}) {
    final name = _path[at];
    if (last) {
      return BreadcrumbPage(seed: 'p-$at', child: Text(name));
    }
    return BreadcrumbLink(onPressed: () => _goTo(at), child: Text(name));
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final folded = _path.length > 4;
    final shown = switch (folded) {
      true => [0, _path.length - 2, _path.length - 1],
      false => [for (var at = 0; at < _path.length; at++) at],
    };
    final hidden = switch (folded) {
      true => _path.sublist(1, _path.length - 2),
      false => const <String>[],
    };
    final children = _tree[_path.last] ?? const <String>[];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: Paper(
        seed: 'path',
        padding: const EdgeInsets.all(Spacing.d20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            Breadcrumb(
              child: BreadcrumbList(
                children: [
                  for (final (i, at) in shown.indexed) ...[
                    BreadcrumbItem(
                      children: [_crumb(at, last: i == shown.length - 1)],
                    ),
                    if (i == 0 && folded) ...[
                      const BreadcrumbSeparator(),
                      BreadcrumbItem(
                        children: [
                          DropdownMenu(
                            content: DropdownMenuContent(
                              align: OverlayAlign.start,
                              children: [
                                for (final (k, folder) in hidden.indexed)
                                  DropdownMenuItem(
                                    leading: const InkIcon('folder'),
                                    onSelect: () => _goTo(k + 1),
                                    child: Text(folder),
                                  ),
                              ],
                            ),
                            child: DropdownMenuTrigger.builder(
                              builder: (context, menu) => BreadcrumbLink(
                                onPressed: menu.toggle,
                                forcedStates: {
                                  if (menu.open) InkState.hovered,
                                },
                                child: const BreadcrumbEllipsis(
                                  semanticLabel: 'Show hidden folders',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (i < shown.length - 1) const BreadcrumbSeparator(),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d4,
              children: [
                for (final child in children)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: BreadcrumbLink(
                      onPressed: () =>
                          setState(() => _path = [..._path, child]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Spacing.d8,
                        children: [const InkIcon('folder'), Text(child)],
                      ),
                    ),
                  ),
                if (children.isEmpty)
                  Text(
                    'This folder is empty. Go back up with the path above.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
