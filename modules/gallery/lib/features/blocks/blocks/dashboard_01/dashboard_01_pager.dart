import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Under the table: how many rows are ticked, rows per page, the page
/// number and the page buttons (first and last only on wide screens).
class Dashboard01Pager extends StatelessWidget {
  const Dashboard01Pager({
    super.key,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.selectedCount,
    required this.rowCount,
    required this.onPage,
    required this.onPageSize,
  });

  /// Upstream's `lg` window, less the sidebar and the page's margins.
  static const double _wideFrom = 672;
  static const double _pageSizeWidth = 80;
  static const List<int> _pageSizes = [5, 10, 20];

  final int page;
  final int pageCount;
  final int pageSize;
  final int selectedCount;
  final int rowCount;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onPageSize;

  Widget _button(String icon, String label, int to, bool enabled) => Button(
    variant: ButtonVariant.outline,
    size: ButtonSize.icon,
    semanticLabel: label,
    disabled: !enabled,
    onPressed: () => onPage(to),
    child: InkIcon(icon),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final bold = theme.typography
        .interface(cssSize: 14)
        .copyWith(fontWeight: FontWeight.w700);
    final first = page > 0;
    final last = page < pageCount - 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideFrom;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
          child: Row(
            spacing: Spacing.d32,
            children: [
              Expanded(
                child: switch (wide) {
                  true => Text(
                    '$selectedCount of $rowCount row(s) selected.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkSoft,
                    ),
                  ),
                  false => Semantics(
                    liveRegion: true,
                    child: Text('Page ${page + 1} of $pageCount', style: bold),
                  ),
                },
              ),
              if (wide)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d8,
                  children: [
                    Text('Rows per page', style: bold),
                    SizedBox(
                      width: _pageSizeWidth,
                      child: Select(
                        value: '$pageSize',
                        onChanged: (value) => onPageSize(int.parse(value)),
                        content: SelectContent(
                          side: OverlaySide.top,
                          children: [
                            for (final size in _pageSizes)
                              SelectItem(value: '$size', child: Text('$size')),
                          ],
                        ),
                        child: const SelectTrigger(
                          size: SelectSize.sm,
                          semanticLabel: 'Rows per page',
                        ),
                      ),
                    ),
                  ],
                ),
              if (wide)
                Semantics(
                  liveRegion: true,
                  child: Text('Page ${page + 1} of $pageCount', style: bold),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  if (wide)
                    _button('chevrons-left', 'Go to first page', 0, first),
                  _button(
                    'chevron-left',
                    'Go to previous page',
                    page - 1,
                    first,
                  ),
                  _button('chevron-right', 'Go to next page', page + 1, last),
                  if (wide)
                    _button(
                      'chevrons-right',
                      'Go to last page',
                      pageCount - 1,
                      last,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
