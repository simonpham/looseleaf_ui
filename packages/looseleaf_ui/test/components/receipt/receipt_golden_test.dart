import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _cafe() => const Receipt(
  seed: 'till',
  semanticLabel: 'Receipt from Looseleaf Cafe',
  children: [
    ReceiptHeader(
      children: [
        Text('Looseleaf Cafe'),
        Text("12 rue de l'Eau"),
        Text('25 sep 2026 14:02'),
      ],
    ),
    ReceiptLines(
      children: [
        ReceiptLine(qty: 1, price: Text('4.50'), child: Text('oat latte')),
        ReceiptLine(qty: 1, price: Text('3.40'), child: Text('flat white')),
        ReceiptLine(
          qty: 2,
          price: Text('6.20'),
          child: Text('almond croissant'),
        ),
      ],
    ),
    ReceiptTotal(child: Text('14.10')),
    ReceiptFooter(Text('thank you - come again')),
  ],
);

Widget _stationer() => const Receipt(
  fastener: FastenerKind.clip,
  fastenerTone: Accent.sky,
  seed: 'checked',
  children: [
    ReceiptHeader(
      children: [Text('The Stationer'), Text('25 sep 2026 09:41')],
    ),
    ReceiptLines(
      children: [
        ReceiptLine(qty: 3, price: Text('9.00'), child: Text('washi tape')),
        ReceiptLine(price: Text('2.10'), child: Text('glue stick')),
        ReceiptLine(qty: 12, price: Text('18.00'), child: Text('felt tips')),
      ],
    ),
    ReceiptTotal(
      circled: ReceiptPen.redfelt,
      seed: 'loop',
      child: Text('29.10'),
    ),
    ReceiptBarcode(value: '0042 1187 0925'),
    ReceiptFooter(Text('keep for your records')),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('receipt-ends in the light theme', (tester) async {
    tester.view.physicalSize = const Size(2400, 1300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.d40,
                Spacing.d64,
                Spacing.d40,
                Spacing.d40,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d32,
                children: [
                  _cafe(),
                  _stationer(),
                  SizedBox(
                    width: 400,
                    child: Wrap(
                      spacing: Spacing.d32,
                      runSpacing: Spacing.d40,
                      children: [
                        for (final ends in [
                          EdgeKind.zig,
                          EdgeKind.perf,
                          EdgeKind.torn,
                          EdgeKind.cut,
                        ])
                          Receipt(
                            ends: ends,
                            width: 176,
                            seed: ends.name,
                            children: [
                              ReceiptHeader(children: [Text(ends.name)]),
                              const ReceiptLines(
                                children: [
                                  ReceiptLine(
                                    price: Text('2.20'),
                                    child: Text('tea'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/receipt-ends.png'),
    );
  });
}
