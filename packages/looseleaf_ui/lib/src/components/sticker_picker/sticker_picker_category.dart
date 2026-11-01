import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A batch filter in a sticker picker: bold hand lettering in pencil that
/// darkens on hover and sits in a highlighter swipe when [pressed] (or
/// focused by keyboard).
///
/// Mirrors the category buttons in upstream
/// `src/components/ui/sticker-picker.tsx`.
class StickerPickerCategory extends StatefulWidget {
  const StickerPickerCategory({
    super.key,
    required this.label,
    required this.pressed,
    required this.onPressed,
  });

  final String label;

  /// The filter is on.
  final bool pressed;

  final VoidCallback onPressed;

  /// Upstream's `ll-swipe` corners.
  static const BorderRadius swipe = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  @override
  State<StickerPickerCategory> createState() => _StickerPickerCategoryState();
}

class _StickerPickerCategoryState extends State<StickerPickerCategory> {
  bool _hovered = false;
  bool _focusVisible = false;

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onPressed();
        return null;
      },
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final swiped = widget.pressed || _focusVisible;
    final strong = swiped || _hovered;
    return Semantics(
      container: true,
      button: true,
      toggled: widget.pressed,
      onTap: widget.onPressed,
      child: FocusableActionDetector(
        actions: _actions,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (visible) =>
            setState(() => _focusVisible = visible),
        onShowHoverHighlight: (hovered) => setState(() => _hovered = hovered),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: InkMotion.of(context, InkMotion.hover),
            constraints: const BoxConstraints(minHeight: Spacing.d24),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
            decoration: BoxDecoration(
              color: switch (swiped) {
                true => theme.colors.hiSelect,
                false => theme.colors.hiSelect.withValues(alpha: 0),
              },
              borderRadius: StickerPickerCategory.swipe,
            ),
            child: Text(
              widget.label,
              maxLines: 1,
              softWrap: false,
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 14,
                cssLineHeight: 20 / 14,
                fontWeight: FontWeight.w700,
                color: switch (strong) {
                  true => theme.colors.ink,
                  false => theme.colors.inkMuted,
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
