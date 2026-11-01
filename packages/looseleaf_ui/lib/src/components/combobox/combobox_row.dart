import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A list row's look, shared by [ComboboxItem] and [ComboboxCreate]: a
/// 36 px hand-lettered row that wears the highlighter swipe while
/// [active], graphite when [disabled], with an optional [trailing] mark at
/// its end.
///
/// Mirrors upstream `CommandItem` (`src/components/ui/command.tsx`).
class ComboboxRow extends StatelessWidget {
  const ComboboxRow({
    super.key,
    required this.child,
    required this.active,
    this.disabled = false,
    this.leading,
    this.trailing,
    this.color,
    this.onHover,
    this.onTap,
  });

  final Widget child;

  /// Highlighted by the keys or the pointer (`data-selected`).
  final bool active;

  final bool disabled;

  /// An icon before the text.
  final Widget? leading;

  /// A mark at the end, like the chosen tick.
  final Widget? trailing;

  /// The text color over the foreground.
  final Color? color;

  final VoidCallback? onHover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    final color = switch ((disabled, active)) {
      (true, _) => theme.colors.pencilText,
      (false, true) => theme.colors.selectionText,
      (false, false) => this.color ?? theme.colors.ink,
    };
    final row = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: ComboboxMetrics.rowHeight.resolve(theme.density),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: switch (active && !disabled) {
            true => theme.colors.hiSelect,
            false => null,
          },
          borderRadius: ComboboxMetrics.swipe,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: Spacing.d8,
            end: Spacing.d32,
            top: switch (calm) {
              true => Spacing.d4,
              false => Spacing.d6,
            },
            bottom: switch (calm) {
              true => Spacing.d4,
              false => Spacing.d6,
            },
          ),
          child: InkContent(
            style: ComboboxMetrics.text(theme, color: color),
            iconSize: Spacing.d16,
            child: IconTheme.merge(
              data: IconThemeData(
                color: switch (disabled) {
                  true => theme.colors.pencilText,
                  false => theme.colors.inkSoft,
                },
              ),
              child: Row(
                spacing: Spacing.d8,
                children: [
                  ?leading,
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return MouseRegion(
      onEnter: switch (disabled) {
        true => null,
        false => (_) => onHover?.call(),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: switch (disabled) {
          true => null,
          false => onTap,
        },
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: [
            row,
            if (trailing case final mark?)
              PositionedDirectional(end: Spacing.d8, child: mark),
          ],
        ),
      ),
    );
  }
}
