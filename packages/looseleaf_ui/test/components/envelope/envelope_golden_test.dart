import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _post({
  required String seed,
  bool? open,
  StockName stock = StockName.kraft,
  Accent? stamp = Accent.tomato,
  bool airmail = false,
  double? tilt,
  double maxWidth = Envelope.defaultMaxWidth,
  Set<InkState> forcedStates = const {},
  List<Widget> address = const [Text('Ada Lovelace'), Text('Paris')],
}) => Envelope(
  seed: seed,
  open: open,
  stock: stock,
  stamp: stamp,
  airmail: airmail,
  tiltDegrees: tilt,
  maxWidth: maxWidth,
  forcedStates: forcedStates,
  children: [
    EnvelopeFront(
      children: [
        if (maxWidth == Envelope.defaultMaxWidth)
          const EnvelopeSender(child: Text('The Stationer\nHigh Street')),
        EnvelopeAddress(
          cssFontSize: switch (maxWidth == Envelope.defaultMaxWidth) {
            true => 21.6,
            false => 17.6,
          },
          children: address,
        ),
        const EnvelopeTrigger(),
      ],
    ),
    const EnvelopeLetter(
      seed: 'letter',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d8,
        children: [
          Text('Dear Ada,'),
          Text('The flap is up and the letter comes out from behind.'),
        ],
      ),
    ),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('envelope-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1800, 1300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d40),
              child: SizedBox(
                width: 820,
                child: Wrap(
                  spacing: Spacing.d48,
                  runSpacing: Spacing.d48,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    _post(seed: 'post', open: true),
                    _post(seed: 'shut', forcedStates: {InkState.hovered}),
                    _post(
                      seed: 'a',
                      tilt: -1,
                      maxWidth: 208,
                      address: const [
                        Text('The Stationer'),
                        Text('High Street'),
                      ],
                    ),
                    _post(
                      seed: 'b',
                      stock: StockName.paper,
                      stamp: Accent.sky,
                      tilt: 0.8,
                      maxWidth: 208,
                      address: const [Text('Marguerite'), Text('Lyon')],
                    ),
                    _post(
                      seed: 'c',
                      stock: StockName.paper,
                      stamp: Accent.tangerine,
                      airmail: true,
                      tilt: -0.6,
                      maxWidth: 208,
                      address: const [
                        Text('Ms. A. Lovelace'),
                        Text('Par avion'),
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
      matchesGoldenFile('../goldens/envelope-states.png'),
    );
  });
}
