import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypographyTableExample extends StatelessWidget {
  const TypographyTableExample({super.key});

  static const _rows = [
    ('Empty', 'Overflowing'),
    ('Modest', 'Satisfied'),
    ('Full', 'Ecstatic'),
  ];

  @override
  Widget build(BuildContext context) => Prose(
    children: [
      InkTable(
        header: const TableHeader(
          rows: [
            InkTableRow(
              cells: [
                TableHead(child: Text("King's Treasury")),
                TableHead(child: Text("People's happiness")),
              ],
            ),
          ],
        ),
        body: TableBody(
          rows: [
            for (final (treasury, happiness) in _rows)
              InkTableRow(
                cells: [
                  InkTableCell(child: Text(treasury)),
                  InkTableCell(child: Text(happiness)),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}
