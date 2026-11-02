import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupMessageComposerExample extends StatefulWidget {
  const ButtonGroupMessageComposerExample({super.key});

  @override
  State<ButtonGroupMessageComposerExample> createState() =>
      _ButtonGroupMessageComposerExampleState();
}

class _ButtonGroupMessageComposerExampleState
    extends State<ButtonGroupMessageComposerExample> {
  static const _maxWidth = Spacing.d448;

  var _voice = false;

  @override
  Widget build(BuildContext context) => TooltipProvider(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: ButtonGroup(
        semanticLabel: 'New message',
        children: [
          ButtonGroup(
            children: [
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.icon,
                semanticLabel: 'Attach',
                onPressed: () {},
                child: const InkIcon('plus'),
              ),
            ],
          ),
          Expanded(
            child: ButtonGroup(
              children: [
                Expanded(
                  child: InputGroup(
                    disabled: _voice,
                    children: [
                      InputGroupInput(
                        placeholder: switch (_voice) {
                          true => 'Record and send audio...',
                          false => 'Send a message...',
                        },
                        semanticLabel: 'Message',
                      ),
                      InputGroupAddon(
                        align: InputGroupAlign.inlineEnd,
                        child: Tooltip(
                          content: const TooltipContent(
                            child: Text('Voice mode'),
                          ),
                          child: Semantics(
                            toggled: _voice,
                            child: InputGroupButton(
                              size: InputGroupButtonSize.iconXs,
                              variant: switch (_voice) {
                                true => ButtonVariant.secondary,
                                false => ButtonVariant.ghost,
                              },
                              semanticLabel: 'Voice mode',
                              onPressed: () => setState(() => _voice = !_voice),
                              child: const InkIcon('audio-lines'),
                            ),
                          ),
                        ),
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
  );
}
