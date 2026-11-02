import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerPickerDefaultExample extends StatefulWidget {
  const StickerPickerDefaultExample({super.key});

  @override
  State<StickerPickerDefaultExample> createState() =>
      _StickerPickerDefaultExampleState();
}

class _StickerPickerDefaultExampleState
    extends State<StickerPickerDefaultExample> {
  static const _stickerSize = 88.0;

  String? _name;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Spacing.d16,
      children: [
        StickerPicker(
          value: _name,
          onSelect: (sticker) => setState(() => _name = sticker.name),
          content: const StickerPickerContent(),
          child: StickerPickerTrigger.builder(
            builder: (context, popover) => Button(
              variant: ButtonVariant.outline,
              onPressed: popover.toggle,
              leading: const InkIcon('star'),
              child: const Text('Add sticker'),
            ),
          ),
        ),
        Semantics(
          liveRegion: true,
          child: SizedBox.square(
            dimension: Spacing.d112,
            child: Center(
              child: switch (_name) {
                final name? => Sticker(
                  name,
                  size: _stickerSize,
                  semanticLabel: 'Chosen: $name',
                ),
                null => Text(
                  'none yet',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 20,
                    color: theme.colors.inkMuted,
                  ),
                ),
              },
            ),
          ),
        ),
      ],
    );
  }
}
