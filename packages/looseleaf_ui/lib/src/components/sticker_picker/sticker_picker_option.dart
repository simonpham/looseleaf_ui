import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/sticker/sticker.dart';
import 'package:looseleaf_ui/src/components/sticker_picker/sticker_picker.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One sticker in a picker's grid, [size] + 12 px tall. The [active] one
/// (under the pointer or the arrow keys) sits in a highlighter swipe,
/// curls a corner, tilts and lifts; the [selected] one has a tick. It
/// scrolls itself into view when it turns active.
///
/// Mirrors `Option` in upstream `src/components/ui/sticker-picker.tsx`.
class StickerPickerOption extends StatefulWidget {
  const StickerPickerOption({
    super.key,
    required this.entry,
    required this.size,
    required this.active,
    required this.selected,
    required this.onActivate,
    required this.onChoose,
    this.scope = '',
  });

  final StickerPickerItem entry;

  /// The sticker's size in pixels.
  final double size;

  /// Under the pointer or the arrow keys.
  final bool active;

  /// The picker's value.
  final bool selected;

  /// Called when the pointer moves over it.
  final VoidCallback onActivate;

  /// Called when it is clicked.
  final VoidCallback onChoose;

  /// Keeps its drawing ids apart from the same sticker elsewhere.
  final String scope;

  @override
  State<StickerPickerOption> createState() => _StickerPickerOptionState();
}

class _StickerPickerOptionState extends State<StickerPickerOption> {
  @override
  void initState() {
    super.initState();
    if (widget.active) _reveal();
  }

  @override
  void didUpdateWidget(StickerPickerOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _reveal();
  }

  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.findRenderObject()?.showOnScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final entry = widget.entry;
    final active = widget.active;
    final duration = InkMotion.of(context, InkMotion.hover);
    final art = StickerFaceArt(
      name: entry.name,
      size: widget.size,
      seed: entry.name,
      peel: active,
      shadow: active,
      idPrefix: 'll-sp${widget.scope}${entry.name}'.replaceAll(
        RegExp('[^a-zA-Z0-9-]'),
        '',
      ),
    );
    if (art.face == null) return const SizedBox.shrink();
    return Semantics(
      container: true,
      button: true,
      selected: widget.selected,
      label: entry.label,
      onTap: widget.onChoose,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (_) {
          if (!active) widget.onActivate();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.onChoose,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: switch (active) {
                true => theme.colors.hiSelect,
                false => null,
              },
              borderRadius: StickerPickerCategory.swipe,
            ),
            child: SizedBox(
              height: widget.size + Spacing.d12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  ExcludeSemantics(
                    child: AnimatedRotation(
                      turns: switch (active) {
                        true => -3 / 360,
                        false => 0,
                      },
                      duration: duration,
                      curve: InkMotion.settle,
                      child: AnimatedScale(
                        scale: switch (active) {
                          true => 1.1,
                          false => 1,
                        },
                        duration: duration,
                        curve: InkMotion.settle,
                        child: art,
                      ),
                    ),
                  ),
                  if (widget.selected)
                    PositionedDirectional(
                      top: Spacing.d2,
                      end: Spacing.d2,
                      child: InkIcon(
                        'check',
                        size: Spacing.d14,
                        color: theme.colors.ink,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
