import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerPickerASmallSetExample extends StatefulWidget {
  const StickerPickerASmallSetExample({super.key});

  @override
  State<StickerPickerASmallSetExample> createState() =>
      _StickerPickerASmallSetExampleState();
}

class _StickerPickerASmallSetExampleState
    extends State<StickerPickerASmallSetExample> {
  static const _reactions = [
    StickerPickerInput(
      'thumbs-up',
      label: 'Nice',
      category: 'Reactions',
      tags: ['like', 'good'],
    ),
    StickerPickerInput(
      'party-popper',
      label: 'Celebrate',
      category: 'Reactions',
      tags: ['party', 'yay'],
    ),
    StickerPickerInput(
      'heart-eyes',
      label: 'Love it',
      category: 'Reactions',
      tags: ['love', 'heart'],
    ),
    StickerPickerInput(
      'thinking-face',
      label: 'Hmm',
      category: 'Reactions',
      tags: ['think', 'unsure'],
    ),
    StickerPickerInput(
      'done',
      label: 'Done',
      category: 'Reactions',
      tags: ['finished', 'complete'],
    ),
    StickerPickerInput(
      'wow',
      label: 'Wow',
      category: 'Reactions',
      tags: ['surprised'],
    ),
    StickerPickerInput(
      'ok',
      label: 'OK',
      category: 'Reactions',
      tags: ['fine', 'agree'],
    ),
    StickerPickerInput(
      'eyes-look',
      label: 'Looking',
      category: 'Reactions',
      tags: ['watching', 'see'],
    ),
  ];

  List<String> _mine = const [];

  void _toggle(String name) => setState(
    () => _mine = switch (_mine.contains(name)) {
      true => [
        for (final mine in _mine)
          if (mine != name) mine,
      ],
      false => [..._mine, name],
    },
  );

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d12,
    children: [
      StickerPicker(
        stickers: _reactions,
        closeOnSelect: false,
        onSelect: (sticker) => _toggle(sticker.name),
        value: _mine.lastOrNull,
        content: const StickerPickerContent(columns: 4, size: Spacing.d48),
        child: StickerPickerTrigger.builder(
          builder: (context, popover) => Button(
            variant: ButtonVariant.secondary,
            size: ButtonSize.sm,
            onPressed: popover.toggle,
            child: const Text('React'),
          ),
        ),
      ),
      Semantics(
        label: 'Your reactions',
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.d56),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d4,
            children: [
              for (final name in _mine)
                Sticker(
                  name,
                  key: ValueKey(name),
                  size: Spacing.d48,
                  semanticLabel: name,
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
