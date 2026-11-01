import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';

const _commands = [
  ('summarize', 'Sum up the thread'),
  ('draw', 'Sketch a diagram'),
  ('clear', 'Start a fresh page'),
];

class _Commands extends StatelessWidget {
  const _Commands();

  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    return PromptInputSuggestions(
      trigger: '/',
      children: [
        for (final (name, hint) in _commands)
          PromptInputSuggestion(
            onSelect: () => model.replaceTrigger('/$name'),
            disabled: name == 'clear',
            children: [
              const InkIcon('slash', size: Spacing.d14, seed: 'slash'),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              Flexible(
                child: Text(
                  hint,
                  style: TextStyle(
                    color: LooseleafTheme.of(context).colors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

Widget _composer({
  required String seed,
  String text = '',
  PromptInputStatus status = PromptInputStatus.ready,
  bool disabled = false,
  bool tools = true,
  List<Widget> above = const [],
}) => PromptInput(
  seed: seed,
  status: status,
  disabled: disabled,
  controller: TextEditingController.fromValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  ),
  triggers: const [PromptInputTrigger('/', atStart: true)],
  children: [
    ...above,
    PromptInputBody(seed: seed, child: const PromptInputTextarea()),
    PromptInputFooter(
      children: [
        if (tools)
          PromptInputTools(
            children: [
              PromptInputButton(
                size: ButtonSize.iconSm,
                semanticLabel: 'Attach a file',
                seed: '$seed-clip',
                onPressed: () {},
                child: const InkIcon('paperclip', seed: 'clip'),
              ),
            ],
          ),
        PromptInputHint(
          Text(switch (status.busy) {
            true => 'Press stop to interrupt',
            false => 'Enter to send, Shift+Enter for a new line',
          }),
        ),
        PromptInputSubmit(seed: '$seed-send'),
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

  testWidgets('prompt-input-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1300, 1900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      RepaintBoundary(
        child: overlayHost(
          SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d24,
              children: [
                const SizedBox(height: Spacing.d112),
                _composer(
                  seed: 'menu',
                  text: '/',
                  tools: false,
                  above: const [
                    _Commands(),
                  ],
                ),
                _composer(seed: 'composer'),
                _composer(
                  seed: 'typed',
                  text: 'Sketch the pond, with ducks\nand the big umbrella',
                ),
                _composer(
                  seed: 'stream',
                  text: 'what next?',
                  status: PromptInputStatus.streaming,
                ),
                _composer(seed: 'off', disabled: true, tools: false),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/prompt-input-states.png'),
    );
  });
}
