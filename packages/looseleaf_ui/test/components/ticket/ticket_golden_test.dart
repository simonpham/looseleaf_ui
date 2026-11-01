import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('ticket-stubs in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1200, 1640);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: const Padding(
              padding: EdgeInsets.all(Spacing.d40),
              child: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d36,
                  children: [
                    Ticket(
                      seed: 'admit',
                      children: [
                        TicketBody(
                          children: [
                            TicketTitle(Text('Admit one')),
                            TicketDescription(Text('Le Grand Jardin')),
                            TicketNumber(Text('No. 0042')),
                          ],
                        ),
                        TicketStub(
                          children: [
                            TicketNumber(Text('No.'), cssSize: 12),
                            TicketNumber(Text('0042'), cssSize: 18),
                          ],
                        ),
                      ],
                    ),
                    Ticket(
                      stock: StockName.stickyYellow,
                      punched: true,
                      seed: 'cinema',
                      children: [
                        TicketBody(
                          children: [
                            TicketTitle(Text('Cinema')),
                            TicketDescription(Text('Sat 27 Sep - 19:30')),
                            TicketNumber(Text('Screen 2 - Row F - Seat 14')),
                          ],
                        ),
                        TicketStub(
                          children: [TicketNumber(Text('1187'), cssSize: 18)],
                        ),
                      ],
                    ),
                    Ticket(
                      stock: StockName.indexCard,
                      stub: TicketStubSide.start,
                      stubWidth: 80,
                      seed: 'raffle',
                      children: [
                        TicketBody(
                          children: [
                            TicketTitle(Text('Raffle')),
                            TicketDescription(Text('Win a very small pencil')),
                          ],
                        ),
                        TicketStub(
                          children: [TicketNumber(Text('311'), cssSize: 20)],
                        ),
                      ],
                    ),
                    Ticket(
                      stock: StockName.stickyPink,
                      stub: TicketStubSide.none,
                      seed: 'tram',
                      children: [
                        TicketBody(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TicketTitle(Text('One ride')),
                            TicketDescription(Text('Good until the last tram')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/ticket-stubs.png'),
    );
  });
}
