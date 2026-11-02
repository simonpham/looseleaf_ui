import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/footer_01/footer_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The footer's link columns: Product, Company and Resources, two columns
/// across on narrow pages and three on wide ones.
///
/// Mirrors upstream `src/blocks/footer-01/components/footer-01-links.tsx`.
class Footer01Links extends StatelessWidget {
  const Footer01Links({super.key, this.columns = 2});

  /// How many link columns sit side by side.
  final int columns;

  static const _columns = [
    (
      title: 'Product',
      links: ['Notebooks', 'Tasks', 'Templates', 'Changelog', 'Pricing'],
    ),
    (title: 'Company', links: ['About', 'Careers', 'Press kit', 'Contact']),
    (
      title: 'Resources',
      links: ['Guides', 'Help center', 'API docs', 'Status', 'Community'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final linkStyle = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 16,
      cssLineHeight: 24 / 16,
    );
    final rows = [
      for (var start = 0; start < _columns.length; start += columns)
        _columns.skip(start).take(columns).toList(),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d40,
      children: [
        for (final row in rows)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              for (var index = 0; index < columns; index++)
                Expanded(
                  child: switch (row.elementAtOrNull(index)) {
                    null => const SizedBox.shrink(),
                    final column => Semantics(
                      container: true,
                      label: column.title,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d12,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              column.title,
                              style: theme.typography.face(
                                KevinSansFace.script,
                                cssSize: 24,
                                cssLineHeight: 1,
                                fontWeight: FontWeight.w700,
                                color: theme.colors.ink,
                              ),
                            ),
                          ),
                          DefaultTextStyle.merge(
                            style: linkStyle,
                            child: _Bleed(
                              child: Transform.translate(
                                offset: Offset(
                                  switch (Directionality.of(context)) {
                                    TextDirection.ltr => -Spacing.d8,
                                    TextDirection.rtl => Spacing.d8,
                                  },
                                  0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Spacing.d2,
                                  children: [
                                    for (final link in column.links)
                                      Footer01Link(link),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  },
                ),
            ],
          ),
      ],
    );
  }
}

/// Lets the links' swipe reach 8 px past the column on both sides, like
/// upstream's `-mx-2 px-2`.
class _Bleed extends StatelessWidget {
  const _Bleed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => OverflowBox(
      alignment: AlignmentDirectional.topStart,
      minWidth: 0,
      maxWidth: constraints.maxWidth + Spacing.d16,
      fit: OverflowBoxFit.deferToChild,
      child: child,
    ),
  );
}
