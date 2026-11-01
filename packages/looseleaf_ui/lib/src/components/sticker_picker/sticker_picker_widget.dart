import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/popover/popover.dart';
import 'package:looseleaf_ui/src/components/sticker_picker/sticker_picker.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A popover for choosing a sticker: a search field, batch filters and a
/// grid of stickers by batch (recent ones first). Arrow keys move through
/// the grid from the search field, Enter or a click chooses.
///
/// [content] (a [StickerPickerContent]) is what pops up; [child] (usually
/// a [StickerPickerTrigger]) opens it. [onSelect] hears the choice and the
/// picker closes unless not [closeOnSelect]. [value] ticks the chosen
/// sticker; [stickers] narrows what is offered (the whole catalog when
/// null); [recent] names stickers listed first. Open state is yours with
/// [open] and [onOpenChange], or the picker's own from [defaultOpen].
///
/// ```dart
/// StickerPicker(
///   value: chosen,
///   onSelect: (sticker) => setState(() => chosen = sticker.name),
///   content: const StickerPickerContent(),
///   child: StickerPickerTrigger.builder(
///     builder: (context, popover) => Button(
///       variant: ButtonVariant.outline,
///       onPressed: popover.toggle,
///       leading: const InkIcon('star'),
///       child: const Text('Add sticker'),
///     ),
///   ),
/// )
/// ```
///
/// Mirrors `StickerPicker` in upstream `src/components/ui/sticker-picker.tsx`.
class StickerPicker extends StatefulWidget {
  const StickerPicker({
    super.key,
    required this.content,
    required this.child,
    this.onSelect,
    this.value,
    this.stickers,
    this.recent = const [],
    this.closeOnSelect = true,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.modal = false,
  });

  /// What pops up.
  final StickerPickerContent content;

  /// The anchor, usually a [StickerPickerTrigger].
  final Widget child;

  /// Called with the chosen sticker.
  final ValueChanged<StickerPickerItem>? onSelect;

  /// The chosen sticker's name, ticked in the grid.
  final String? value;

  /// The stickers on offer; the whole catalog when null.
  final List<StickerPickerInput>? stickers;

  /// Sticker names listed first, under “Recent”.
  final List<String> recent;

  /// Closes the popover once a sticker is chosen.
  final bool closeOnSelect;

  /// Whether it is open; the picker keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// Blocks the app below and keeps focus inside.
  final bool modal;

  /// Upstream's `w-[min(23rem,calc(100vw-2rem))]`.
  static const double width = 368;

  @override
  State<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  late bool _inner = widget.defaultOpen;
  late List<StickerPickerItem> _catalog = StickerPickerInput.catalogFrom(
    widget.stickers,
  );

  bool get _open => widget.open ?? _inner;

  @override
  void didUpdateWidget(StickerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.stickers, widget.stickers)) return;
    _catalog = StickerPickerInput.catalogFrom(widget.stickers);
  }

  void _setOpen(bool next) {
    if (widget.open == null) setState(() => _inner = next);
    widget.onOpenChange?.call(next);
  }

  void _choose(StickerPickerItem item) {
    widget.onSelect?.call(item);
    if (widget.closeOnSelect) _setOpen(false);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    return StickerPickerScope(
      catalog: _catalog,
      recent: widget.recent,
      value: widget.value,
      choose: _choose,
      child: Popover(
        open: _open,
        onOpenChange: _setOpen,
        modal: widget.modal,
        content: PopoverContent(
          side: content.side,
          align: content.align,
          width: StickerPicker.width,
          padding: const EdgeInsets.all(Spacing.d12),
          seed: content.seed,
          semanticLabel: 'Stickers',
          child: content,
        ),
        child: widget.child,
      ),
    );
  }
}
