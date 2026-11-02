import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BreadcrumbSeparatorsExample extends StatelessWidget {
  const BreadcrumbSeparatorsExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      _Trail(label: 'slash (default)'),
      _Trail(label: 'chevron', separator: InkIcon('chevron-right')),
      _Trail(label: 'arrow', separator: InkIcon('arrow-right')),
      _Trail(
        label: 'dot',
        separator: InkIcon('dot', size: Spacing.d20),
      ),
    ],
  );
}

class _Trail extends StatelessWidget {
  const _Trail({required this.label, this.separator});

  static const _trail = ['Notebooks', 'Field notes', 'March'];

  final String label;
  final Widget? separator;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d4,
      children: [
        Text(
          label,
          style: theme.typography.stamp(
            cssSize: 14,
            color: theme.colors.inkMuted,
          ),
        ),
        Breadcrumb(
          child: BreadcrumbList(
            children: [
              for (final (index, name) in _trail.indexed) ...[
                BreadcrumbItem(
                  children: [
                    switch (index == _trail.length - 1) {
                      true => BreadcrumbPage(seed: label, child: Text(name)),
                      false => BreadcrumbLink(
                        onPressed: () {},
                        child: Text(name),
                      ),
                    },
                  ],
                ),
                if (index < _trail.length - 1)
                  BreadcrumbSeparator(child: separator),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
