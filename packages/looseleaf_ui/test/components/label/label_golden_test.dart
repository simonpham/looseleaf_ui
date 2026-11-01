import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _field(Widget label, Widget field) => SizedBox(
  width: 280,
  height: 64,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d8,
    children: [label, field],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('label-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d16,
            children: [
              _field(
                const Label(child: Text('Email')),
                const Input(placeholder: 'you@example.com', seed: 'email'),
              ),
              _field(
                const Label(
                  required: true,
                  seed: 'name',
                  child: Text('Full name'),
                ),
                const Input(placeholder: 'Ada Lovelace', seed: 'name'),
              ),
              _field(
                const Label(disabled: true, child: Text('Account email')),
                const Input(placeholder: 'locked', disabled: true, seed: 'off'),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  Checkbox(value: true, seed: 'terms', onChanged: (_) {}),
                  const Label(child: Text('Accept terms and conditions')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/label-states.png'),
    );
  });
}
