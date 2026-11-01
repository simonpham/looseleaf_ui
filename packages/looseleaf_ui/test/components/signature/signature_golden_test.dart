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

  testWidgets('signature-flourishes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d16,
            children: [
              for (final flourish in SignatureFlourish.values)
                Signature(
                  flourish: flourish,
                  seed: 'flourish-${flourish.name}',
                  child: const Text('Ada Lovelace'),
                ),
              const Signature(
                size: SignatureSize.sm,
                tone: MarkPen.ink,
                seed: 'sm',
                child: Text('Ada Lovelace'),
              ),
              const Signature(
                size: SignatureSize.lg,
                weight: MarkWeight.brush,
                seed: 'lg',
                child: Text('Ada'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/signature-flourishes.png'),
    );
  });
}
