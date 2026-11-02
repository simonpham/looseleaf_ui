import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupCommentBoxExample extends StatefulWidget {
  const InputGroupCommentBoxExample({super.key});

  @override
  State<InputGroupCommentBoxExample> createState() =>
      _InputGroupCommentBoxExampleState();
}

class _InputGroupCommentBoxExampleState
    extends State<InputGroupCommentBoxExample> {
  static const _max = 140;

  String _text = '';

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 448),
    child: InputGroup(
      children: [
        const InputGroupAddon(
          align: InputGroupAlign.blockStart,
          child: Row(
            spacing: Spacing.d8,
            children: [
              InkIcon('message-square'),
              InputGroupText(child: Text('Reply to Ada')),
            ],
          ),
        ),
        InputGroupTextarea(
          placeholder: 'Write something kind...',
          semanticLabel: 'Reply',
          minLines: 3,
          maxLength: _max,
          onChanged: (text) => setState(() => _text = text),
        ),
        InputGroupAddon(
          align: InputGroupAlign.blockEnd,
          child: Row(
            children: [
              InputGroupText(
                child: Text(
                  '${_text.length}/$_max',
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const Spacer(),
              InputGroupButton(
                variant: ButtonVariant.primary,
                size: InputGroupButtonSize.sm,
                disabled: _text.trim().isEmpty,
                leading: const InkIcon('send'),
                onPressed: () {},
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
