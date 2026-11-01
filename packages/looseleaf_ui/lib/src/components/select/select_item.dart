import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One choice in a [SelectContent]: a hand-lettered row that wears the
/// highlighter swipe under the pointer or the keys; the chosen row is
/// bold with a blue tick written on at its end. Disabled rows are
/// graphite and skipped.
///
/// [child] is also what the trigger shows once it is chosen; typeahead
/// reads [textValue], else the text of a [Text] child, else [value].
///
/// Mirrors `SelectItem` in upstream `src/components/ui/select.tsx`.
class SelectItem extends StatelessWidget {
  const SelectItem({
    super.key,
    required this.value,
    required this.child,
    this.textValue,
    this.disabled = false,
  });

  /// The value chosen.
  final String value;

  /// The row's content (upstream's `ItemText`).
  final Widget child;

  /// The words typeahead matches.
  final String? textValue;

  /// Graphite, skipped by the keys, not choosable.
  final bool disabled;

  /// The words typeahead matches and screen readers hear.
  String get label => switch ((textValue, child)) {
    (final text?, _) => text,
    (null, Text(:final data?)) => data,
    _ => value,
  };

  @override
  Widget build(BuildContext context) {
    final select = Select.of(context);
    final theme = LooseleafTheme.of(context);
    final off = disabled || select.disabled;
    final highlighted = select.highlighted == value && !off;
    final chosen = select.value == value;
    final color = switch ((off, highlighted)) {
      (true, _) => theme.colors.pencilText,
      (false, true) => theme.colors.selectionText,
      (false, false) => theme.colors.ink,
    };
    final vertical = SelectMetrics.itemVertical.of(context);
    final row = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: SelectMetrics.itemHeight.of(context),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: switch (highlighted) {
            true => theme.colors.hiSelect,
            false => null,
          },
          borderRadius: SelectMetrics.swipe,
        ),
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Padding(
              padding: SelectMetrics.itemInline.add(
                EdgeInsets.symmetric(vertical: vertical),
              ),
              child: InkContent(
                style: SelectMetrics.text(
                  theme,
                  color: color,
                  fontWeight: switch (chosen) {
                    true => FontWeight.w700,
                    false => FontWeight.w400,
                  },
                ),
                iconSize: Spacing.d16,
                child: child,
              ),
            ),
            if (chosen)
              PositionedDirectional(
                end: SelectMetrics.tickEnd,
                child: InkMarkWipe(
                  duration: InkMotion.sheet,
                  child: InkIcon(
                    'check',
                    size: Spacing.d16,
                    color: theme.colors.inkYou,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return KeyedSubtree(
      key: select.rowKey(value),
      child: Semantics(
        container: true,
        button: true,
        selected: chosen,
        enabled: !off,
        label: label,
        onTap: switch (off) {
          true => null,
          false => () => select.select(value),
        },
        child: ExcludeSemantics(
          child: MouseRegion(
            onEnter: switch (off) {
              true => null,
              false => (_) => select.highlight(value),
            },
            onExit: switch (off) {
              true => null,
              false => (_) => select.highlight(null),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: switch (off) {
                true => null,
                false => () => select.select(value),
              },
              child: row,
            ),
          ),
        ),
      ),
    );
  }
}
