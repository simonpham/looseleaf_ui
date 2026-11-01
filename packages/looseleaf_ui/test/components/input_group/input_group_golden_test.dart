import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _box(Widget child) => SizedBox(width: 320, child: child);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('input-group-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1500, 1100);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d16,
                children: [
                  _box(
                    const InputGroup(
                      seed: 'search',
                      children: [
                        InputGroupAddon(child: InkIcon('search')),
                        InputGroupInput(placeholder: 'Search…'),
                        InputGroupAddon(
                          align: InputGroupAlign.inlineEnd,
                          child: InputGroupText(
                            child: Text('12 results'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _box(
                    InputGroup(
                      seed: 'link',
                      children: [
                        InputGroupInput(
                          controller: TextEditingController(
                            text: 'https://looseleaf.dev/r/notes',
                          ),
                          readOnly: true,
                        ),
                        InputGroupAddon(
                          align: InputGroupAlign.inlineEnd,
                          child: InputGroupButton(
                            size: InputGroupButtonSize.iconXs,
                            semanticLabel: 'Copy',
                            seed: 'copy',
                            onPressed: () {},
                            child: const InkIcon('copy'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _box(
                    const InputGroup(
                      seed: 'focus',
                      forcedStates: {InkState.focused},
                      children: [
                        InputGroupAddon(
                          child: InputGroupText(child: Text('https://')),
                        ),
                        InputGroupInput(placeholder: 'example.com'),
                      ],
                    ),
                  ),
                  _box(
                    InputGroup(
                      seed: 'invalid',
                      invalid: true,
                      children: [
                        const InputGroupAddon(child: InkIcon('mail')),
                        InputGroupInput(
                          controller: TextEditingController(
                            text: 'not-an-email',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _box(
                    InputGroup(
                      seed: 'disabled',
                      disabled: true,
                      children: [
                        const InputGroupInput(
                          placeholder: 'Disabled as a whole',
                        ),
                        InputGroupAddon(
                          align: InputGroupAlign.inlineEnd,
                          child: InputGroupButton(
                            variant: ButtonVariant.secondary,
                            seed: 'send',
                            onPressed: () {},
                            child: const Text('Send'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _box(
                InputGroup(
                  seed: 'comment',
                  children: [
                    const InputGroupAddon(
                      align: InputGroupAlign.blockStart,
                      border: InputGroupEdge.bottom,
                      child: Row(
                        spacing: Spacing.d8,
                        children: [
                          InkIcon('message-square'),
                          InputGroupText(child: Text('Reply to Ada')),
                        ],
                      ),
                    ),
                    const InputGroupTextarea(
                      placeholder: 'Write something kind...',
                      minLines: 3,
                    ),
                    InputGroupAddon(
                      align: InputGroupAlign.blockEnd,
                      child: Row(
                        children: [
                          const InputGroupText(child: Text('0/140')),
                          const Spacer(),
                          InputGroupButton(
                            variant: ButtonVariant.primary,
                            size: InputGroupButtonSize.sm,
                            leading: const InkIcon('send'),
                            seed: 'post',
                            onPressed: () {},
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/input-group-states.png'),
    );
  });
}
