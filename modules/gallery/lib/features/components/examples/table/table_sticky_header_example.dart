import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
final _rows = [
  for (var i = 0; i < 24; i++)
    (
      day: _days[i % 5],
      page: 'Notebook, p. ${12 + i * 3}',
      words: 180 + (i * 97) % 640,
    ),
];

class TableStickyHeaderExample extends StatelessWidget {
  const TableStickyHeaderExample({super.key});

  static const _maxWidth = 512.0;
  static const _maxHeight = 288.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'sticky-table',
          children: [
            CardContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d12,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: _maxHeight),
                    child: SingleChildScrollView(
                      child: InkTable(
                        header: const TableHeader(
                          rows: [
                            InkTableRow(
                              cells: [
                                TableHead(child: Text('Day')),
                                TableHead(child: Text('Page')),
                                TableHead(
                                  child: Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: Text('Words'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        body: TableBody(
                          rows: [
                            for (final row in _rows)
                              InkTableRow(
                                cells: [
                                  InkTableCell(child: Text(row.day)),
                                  InkTableCell(child: Text(row.page)),
                                  InkTableCell(
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Text(
                                        '${row.words}',
                                        style: const TextStyle(
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Twenty-four pages: scroll the list.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
