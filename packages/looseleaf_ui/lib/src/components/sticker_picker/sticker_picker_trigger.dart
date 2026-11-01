import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/popover/popover.dart';

/// The control that opens a `StickerPicker`: a [PopoverTrigger], either a
/// plain [child] that toggles on tap, Enter and Space, or your own control
/// built with the popover's controller.
///
/// Mirrors `StickerPickerTrigger` in upstream
/// `src/components/ui/sticker-picker.tsx`.
class StickerPickerTrigger extends StatelessWidget {
  /// A trigger that toggles on tap, Enter and Space.
  const StickerPickerTrigger({
    super.key,
    required Widget this.child,
    this.focusNode,
    this.autofocus = false,
  }) : builder = null;

  /// A trigger built around your own control (a `Button`'s
  /// `onPressed: popover.toggle`).
  const StickerPickerTrigger.builder({super.key, required this.builder})
    : child = null,
      focusNode = null,
      autofocus = false;

  final Widget? child;

  /// Builds the trigger with the popover's controller.
  final Widget Function(BuildContext context, PopoverController popover)?
  builder;

  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    if (builder case final build?) {
      return PopoverTrigger.builder(builder: build);
    }
    return PopoverTrigger(
      focusNode: focusNode,
      autofocus: autofocus,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
