import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaginationTableFooterExample extends StatefulWidget {
  const PaginationTableFooterExample({super.key});

  @override
  State<PaginationTableFooterExample> createState() =>
      _PaginationTableFooterExampleState();
}

class _PaginationTableFooterExampleState
    extends State<PaginationTableFooterExample> {
  static const _size = 5;
  static const _names = [
    'Field notes',
    'Garden log',
    'Recipes',
    'Trip to Lisbon',
    'Sketches',
    'Reading list',
    'Letters',
    'Budget',
  ];
  static final _rows = [
    for (var i = 0; i < 23; i++)
      (
        name: switch (i >= _names.length) {
          true => '${_names[i % _names.length]} ${i ~/ _names.length + 1}',
          false => _names[i],
        },
        pages: 12 + (i * 37) % 90,
      ),
  ];
  static final _pages = (_rows.length / _size).ceil();

  int _page = 1;

  void _go(int page) => setState(() => _page = page.clamp(1, _pages));

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final from = (_page - 1) * _size;
    final rows = _rows.skip(from).take(_size).toList();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          InkTable(
            header: const TableHeader(
              rows: [
                InkTableRow(
                  cells: [
                    TableHead(child: Text('Notebook')),
                    TableHead(
                      child: Text('Pages', textAlign: TextAlign.end),
                    ),
                  ],
                ),
              ],
            ),
            body: TableBody(
              rows: [
                for (final row in rows)
                  InkTableRow(
                    cells: [
                      InkTableCell(child: Text(row.name)),
                      InkTableCell(
                        child: Text('${row.pages}', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Spacing.d12,
            runSpacing: Spacing.d8,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  '${from + 1}–${from + rows.length} of ${_rows.length}',
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
              Pagination(
                child: PaginationContent(
                  children: [
                    PaginationLink(
                      semanticLabel: 'Go to previous page',
                      disabled: _page == 1,
                      onPressed: () => _go(_page - 1),
                      child: const InkIcon('chevron-left'),
                    ),
                    for (var number = 1; number <= _pages; number++)
                      PaginationLink(
                        isActive: number == _page,
                        semanticLabel: 'Page $number',
                        onPressed: () => _go(number),
                        child: Text('$number'),
                      ),
                    PaginationLink(
                      semanticLabel: 'Go to next page',
                      disabled: _page == _pages,
                      onPressed: () => _go(_page + 1),
                      child: const InkIcon('chevron-right'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
