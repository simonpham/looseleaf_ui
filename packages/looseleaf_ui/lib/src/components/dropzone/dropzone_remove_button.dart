import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The x at the end of a [DropzoneItem]: a 28 px target that wears the
/// highlighter swipe when hovered or focused, with a blue focus outline.
///
/// Mirrors `dropzone-item-remove` in upstream
/// `src/components/ui/dropzone.tsx`.
class DropzoneRemoveButton extends StatelessWidget {
  const DropzoneRemoveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });

  /// The accessible name.
  final String label;

  final VoidCallback onPressed;
  final bool disabled;

  /// Upstream's `ll-swipe` corners.
  static const BorderRadius swipe = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return Semantics(
      container: true,
      button: true,
      label: label,
      enabled: !disabled,
      child: InkInteraction(
        enabled: !disabled,
        onActivate: onPressed,
        mouseCursor: SystemMouseCursors.basic,
        builder: (context, states) {
          final reached =
              states.contains(InkState.hovered) ||
              states.contains(InkState.focused);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: switch (reached) {
                true => colors.hiSelect,
                false => null,
              },
              borderRadius: swipe,
              border: switch (states.contains(InkState.focused)) {
                true => Border.all(color: colors.focus, width: Spacing.d2),
                false => null,
              },
            ),
            child: SizedBox.square(
              dimension: Spacing.d28,
              child: Center(
                child: InkIcon(
                  'x',
                  size: Spacing.d14,
                  color: switch ((disabled, reached)) {
                    (true, _) => colors.pencilText,
                    (false, true) => colors.ink,
                    (false, false) => colors.inkSoft,
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
