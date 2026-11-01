import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';

Widget _otp(
  String name, {
  String text = '',
  bool disabled = false,
  bool invalid = false,
  bool focus = false,
  String placeholder = '',
}) => InputOTP(
  maxLength: 6,
  controller: TextEditingController(text: text),
  disabled: disabled,
  invalid: invalid,
  autofocus: focus,
  placeholder: placeholder,
  children: [
    InputOTPGroup(
      children: [
        for (final index in [0, 1, 2])
          InputOTPSlot(index: index, seed: '$name-$index'),
      ],
    ),
    const InputOTPSeparator(),
    InputOTPGroup(
      children: [
        for (final index in [3, 4, 5])
          InputOTPSlot(index: index, seed: '$name-$index'),
      ],
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

  testWidgets('input-otp-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      overlayHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.paper,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d20,
                children: [
                  _otp('empty'),
                  _otp('active', text: '123', focus: true),
                  _otp('full', text: '482913'),
                  _otp('placeholder', placeholder: '000000'),
                  _otp('invalid', text: 'ABC12', invalid: true),
                  _otp('disabled', text: '12', disabled: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/input-otp-states.png'),
    );
  });
}
