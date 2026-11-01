import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _admit({
  TicketStubSide stub = TicketStubSide.end,
  double stubWidth = 88,
  TextDirection? direction,
}) {
  final ticket = Ticket(
    seed: 't',
    stub: stub,
    stubWidth: stubWidth,
    semanticLabel: 'Ticket 0042',
    children: const [
      TicketBody(
        children: [
          TicketTitle(Text('Admit one')),
          TicketDescription(Text('Le Grand Jardin')),
        ],
      ),
      TicketStub(children: [TicketNumber(Text('0042'))]),
    ],
  );
  return switch (direction) {
    null => ticket,
    final textDirection => Directionality(
      textDirection: textDirection,
      child: ticket,
    ),
  };
}

void main() {
  testWidgets('is at most 512 wide and at least 112 tall', (tester) async {
    await tester.pumpWidget(componentHost(_admit()));
    expect(tester.getSize(find.byType(Ticket)), const Size(512, 112));
    await tester.pumpWidget(
      componentHost(SizedBox(width: 300, child: _admit())),
    );
    expect(tester.getSize(find.byType(Ticket)).width, 300);
  });

  testWidgets('the stub is stubWidth wide at the end', (tester) async {
    await tester.pumpWidget(componentHost(_admit(stubWidth: 120)));
    final ticket = tester.getRect(find.byType(Ticket));
    final stub = tester.getRect(find.byType(TicketStub));
    expect(stub.width, 120);
    expect(stub.right, ticket.right);
    expect(tester.getTopLeft(find.text('Admit one')).dx - ticket.left, 24);
  });

  testWidgets('a start stub and right to left both put it first', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_admit(stub: TicketStubSide.start)));
    var ticket = tester.getRect(find.byType(Ticket));
    expect(tester.getRect(find.byType(TicketStub)).left, ticket.left);
    await tester.pumpWidget(
      componentHost(_admit(direction: TextDirection.rtl)),
    );
    ticket = tester.getRect(find.byType(Ticket));
    expect(tester.getRect(find.byType(TicketStub)).left, ticket.left);
  });

  testWidgets('the body centres its lines top to bottom', (tester) async {
    await tester.pumpWidget(componentHost(_admit()));
    final ticket = tester.getRect(find.byType(Ticket));
    final top = tester.getTopLeft(find.text('Admit one')).dy - ticket.top;
    final bottom =
        ticket.bottom - tester.getBottomLeft(find.text('Le Grand Jardin')).dy;
    expect(top, closeTo(bottom, 1));
  });

  testWidgets('the drawing carries the stub and the punch', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Ticket(
          punched: true,
          stub: TicketStubSide.none,
          stock: StockName.stickyPink,
          children: [
            TicketBody(children: [Text('One ride')]),
          ],
        ),
      ),
    );
    final source =
        tester.widget<InkSurface>(find.byType(InkSurface)).source
            as RecipeInkSource<TicketParams>;
    expect(source.params.punched, isTrue);
    expect(source.params.stub, TicketStubSide.none);
    expect(source.params.stock, StockName.stickyPink);
  });

  testWidgets('the number is red ink, widely tracked', (tester) async {
    await tester.pumpWidget(componentHost(_admit()));
    final colors = const LooseleafThemeData().colors;
    final style = tester
        .widget<RichText>(
          find.descendant(
            of: find.byType(TicketNumber),
            matching: find.byType(RichText),
          ),
        )
        .text
        .style;
    expect(style?.color, Color.lerp(colors.ink, colors.red, 0.6));
    expect(style?.letterSpacing, greaterThan(1));
  });

  testWidgets('is a labelled group with the stub as its own note', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_admit()));
    expect(
      tester.getSemantics(find.text('0042')),
      matchesSemantics(label: '0042'),
    );
    expect(find.bySemanticsLabel(RegExp('^Ticket 0042')), findsOneWidget);
    handle.dispose();
  });
}
