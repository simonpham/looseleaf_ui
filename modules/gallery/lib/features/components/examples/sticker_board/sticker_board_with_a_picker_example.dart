import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerBoardWithAPickerExample extends StatefulWidget {
  const StickerBoardWithAPickerExample({super.key});

  @override
  State<StickerBoardWithAPickerExample> createState() =>
      _StickerBoardWithAPickerExampleState();
}

class _StickerBoardWithAPickerExampleState
    extends State<StickerBoardWithAPickerExample> {
  static const double _canvasHeight = Spacing.d384 + Spacing.d56;

  List<StickerBoardItem> _items = const [];
  String? _selected;
  List<String> _recent = const [];

  void _add(StickerPickerItem sticker, double width) {
    final next = StickerBoardOps.add(
      _items,
      sticker.name,
      canvas: Size(width, _canvasHeight),
    );
    setState(() {
      _items = next;
      _selected = next.last.id;
      _recent = [
        sticker.name,
        ..._recent.where((name) => name != sticker.name),
      ].take(6).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => StickerBoard(
        value: _items,
        onValueChange: (items) => setState(() => _items = items),
        selection: (id: _selected),
        onSelectedIdChange: (id) => setState(() => _selected = id),
        children: [
          Row(
            spacing: Spacing.d12,
            children: [
              StickerPicker(
                recent: _recent,
                onSelect: (sticker) => _add(sticker, constraints.maxWidth),
                content: const StickerPickerContent(),
                child: StickerPickerTrigger.builder(
                  builder: (context, popover) => Button(
                    onPressed: popover.toggle,
                    leading: const InkIcon('plus'),
                    child: const Text('Add sticker'),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  switch (_items.length) {
                    0 => 'Start with a sticker.',
                    final count => '$count on the page',
                  },
                  style: theme.typography.interface(
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const StickerBoardCanvas(
            height: _canvasHeight,
            empty: Text('Nothing stuck down yet. Add a sticker.'),
          ),
          const StickerBoardToolbar(),
        ],
      ),
    );
  }
}
