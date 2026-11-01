import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Future<void> _loadMono() async {
  final bytes = File(
    'assets/fonts/IBMPlexMono-Regular.ttf',
  ).readAsBytesSync();
  await (FontLoader(
    'packages/looseleaf_ui/${LooseleafTypography.monoFamily}',
  )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
      await _loadMono();
    });
  });

  testWidgets('polaroid-scenes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(2400, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.d40,
                Spacing.d64,
                Spacing.d40,
                Spacing.d40,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d24,
                children: [
                  Polaroid(
                    tape: PaperTape.top,
                    seed: 'august',
                    children: [
                      PolaroidImage(
                        scene: PolaroidScene.hills,
                        label: 'Hills, a tree and a sun',
                        seed: 'hills',
                      ),
                      PolaroidCaption(Text('august, finally')),
                    ],
                  ),
                  Polaroid(
                    width: 224,
                    fastener: FastenerKind.pin,
                    seed: 'p2',
                    children: [
                      PolaroidImage(
                        scene: PolaroidScene.sea,
                        date: "'25 8 09",
                        seed: 's2',
                      ),
                      PolaroidCaption(Text('the ferry home')),
                    ],
                  ),
                  Polaroid(
                    width: 224,
                    fastener: FastenerKind.clip,
                    seed: 'p3',
                    children: [
                      PolaroidImage(scene: PolaroidScene.house, seed: 's3'),
                      PolaroidCaption(Text("gran's house")),
                    ],
                  ),
                  Polaroid(
                    width: 224,
                    tape: PaperTape.both,
                    tapeKind: TapeKind.washiDots,
                    seed: 'p4',
                    children: [
                      PolaroidImage(
                        scene: PolaroidScene.night,
                        date: "'25 9 24",
                        seed: 's4',
                      ),
                      PolaroidCaption(Text('last night, 11pm')),
                    ],
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
      matchesGoldenFile('../goldens/polaroid-scenes.png'),
    );
  });
}
