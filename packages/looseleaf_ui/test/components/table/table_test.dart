import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

InkTable _table({bool selected = false, VoidCallback? onTap}) => InkTable(
  header: const TableHeader(
    rows: [
      InkTableRow(
        cells: [
          TableHead(child: Text('Invoice')),
          TableHead(sort: TableSort.ascending, child: Text('Amount')),
        ],
      ),
    ],
  ),
  body: TableBody(
    rows: [
      InkTableRow(
        selected: selected,
        onTap: onTap,
        cells: const [
          InkTableCell(child: Text('INV001')),
          InkTableCell(child: Text(r'$250.00')),
        ],
      ),
      const InkTableRow(
        cells: [
          InkTableCell(child: Text('INV002')),
          InkTableCell(child: Text(r'$150.00')),
        ],
      ),
    ],
  ),
  footer: const TableFooter(
    rows: [
      InkTableRow(
        cells: [
          InkTableCell(child: Text('Total')),
          InkTableCell(child: Text(r'$400.00')),
        ],
      ),
    ],
  ),
  caption: const TableCaption(child: Text('Recent invoices.')),
);

Iterable<TableCellPainter> _painters(WidgetTester tester) => tester
    .widgetList<CustomPaint>(
      find.descendant(
        of: find.byType(InkTable),
        matching: find.byType(CustomPaint),
      ),
    )
    .map((paint) => paint.painter)
    .whereType<TableCellPainter>();

TextStyle? _style(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style;

void main() {
  const colors = LooseleafColors();

  test('the mask tiles parse', () {
    final tiles = TableTileDocuments.instance;
    for (final document in [
      tiles.rule,
      tiles.head,
      tiles.capStart,
      tiles.capEnd,
    ]) {
      expect(document.layers['rest']?.children, isNotEmpty);
    }
  });

  testWidgets('rows are 44 tall, 36 compact, 32 calm', (tester) async {
    for (final (density, height) in [
      (LooseleafDensity.comfortable, 44.0),
      (LooseleafDensity.compact, 36.0),
      (LooseleafDensity.calm, 32.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          const SizedBox(
            width: 400,
            child: InkTable(
              body: TableBody(
                rows: [
                  InkTableRow(cells: [SizedBox(height: 10, child: Text('x'))]),
                ],
              ),
            ),
          ),
          theme: LooseleafThemeData(density: density),
        ),
      );
      final cell = find
          .ancestor(of: find.text('x'), matching: find.byType(CustomPaint))
          .first;
      expect(tester.getSize(cell).height, height);
    }
  });

  testWidgets('titles are blue script, ink when sorted; the footer is bold', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(SizedBox(width: 400, child: _table())),
    );
    expect(_style(tester, 'Invoice')?.color, colors.inkYou);
    expect(_style(tester, 'Amount')?.color, colors.ink);
    expect(_style(tester, 'Total')?.fontWeight, FontWeight.w700);
    expect(_style(tester, 'INV001')?.fontWeight, isNot(FontWeight.w700));
  });

  testWidgets(
    'rules: under the header and between body rows, over the footer',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        componentHost(SizedBox(width: 400, child: _table())),
      );
      final painters = _painters(tester).toList();
      String key(TableCellPainter painter) =>
          '${painter.section.name}${painter.row}:${painter.rule}';
      expect(painters.map(key).toSet(), {
        'header0:true',
        'body0:true',
        'body1:false',
        'footer0:true',
      });
      expect(painters.first.first, isTrue);
      expect(painters.elementAt(1).last, isTrue);
    },
  );

  testWidgets('the band shows on hover and fills when selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(SizedBox(width: 400, child: _table())),
    );
    double band(String text) => _painters(tester)
        .firstWhere(
          (painter) =>
              painter.section == TableSection.body &&
              painter.row ==
                  switch (text) {
                    'INV001' => 0,
                    _ => 1,
                  },
        )
        .band
        .value;
    expect(band('INV001'), 0);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('INV001')));
    await tester.pump();
    expect(band('INV001'), 0.4);
    await mouse.moveTo(tester.getCenter(find.text('INV002')));
    await tester.pump();
    expect(band('INV001'), 0);
    expect(band('INV002'), 0.4);
    await mouse.removePointer();
    await tester.pumpWidget(
      componentHost(SizedBox(width: 400, child: _table(selected: true))),
    );
    expect(band('INV001'), 1);
  });

  testWidgets('rows answer taps; columns fill the width', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      componentHost(SizedBox(width: 400, child: _table(onTap: () => taps++))),
    );
    await tester.tap(find.text(r'$250.00'));
    expect(taps, 1);
    expect(tester.getSize(find.byType(Table)).width, 400);
  });

  InkTable longTable({required bool wrap}) => InkTable(
    body: TableBody(
      rows: [
        InkTableRow(
          cells: [
            const InkTableCell(child: Text('Name')),
            InkTableCell(
              wrap: wrap,
              child: const Text(
                'a long note that runs far past the width of the table',
              ),
            ),
          ],
        ),
      ],
    ),
  );

  testWidgets('wrapping cells fit the width; one-line cells scroll', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(SizedBox(width: 200, child: longTable(wrap: true))),
    );
    expect(tester.getSize(find.byType(Table)).width, 200);
    expect(
      tester.getSize(find.textContaining('a long note')).height,
      greaterThan(40),
    );

    await tester.pumpWidget(
      componentHost(SizedBox(width: 200, child: longTable(wrap: false))),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(Table)).width, greaterThan(200));
    final paragraph = tester.renderObject<RenderParagraph>(
      find.textContaining('a long note'),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
  });
}
