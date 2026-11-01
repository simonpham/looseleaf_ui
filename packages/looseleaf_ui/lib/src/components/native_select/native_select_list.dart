import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select_metrics.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select_option.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The open list of a [NativeSelect]: group captions, options in the
/// select's type, a highlighter wash on the highlighted option and a tick
/// on the chosen one.
///
/// It only draws and reports taps and hovers; the select owns the keys.
class NativeSelectList<T> extends StatelessWidget {
  const NativeSelectList({
    super.key,
    required this.entries,
    required this.value,
    required this.highlighted,
    required this.onHighlight,
    required this.onSelect,
    required this.style,
  });

  final List<NativeSelectEntry<T>> entries;

  /// The chosen value.
  final T? value;

  /// The highlighted option, as an index into the flattened options.
  final int highlighted;

  /// Called with an option's index when the pointer moves onto it.
  final ValueChanged<int> onHighlight;

  /// Called with an option's index when it is tapped.
  final ValueChanged<int> onSelect;

  /// The option text style.
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    var index = 0;
    final rows = <Widget>[];
    for (final entry in entries) {
      switch (entry) {
        case NativeSelectOption<T>():
          rows.add(_option(theme, entry, index++, grouped: false));
        case NativeSelectOptGroup<T>(:final label, :final options):
          rows.add(
            ExcludeSemantics(
              child: Padding(
                padding: NativeSelectMetrics.optionPadding,
                child: Text(
                  label,
                  style: style.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
            ),
          );
          for (final option in options) {
            rows.add(
              _option(
                theme,
                switch (entry.disabled) {
                  true => NativeSelectOption(
                    value: option.value,
                    label: option.label,
                    disabled: true,
                  ),
                  false => option,
                },
                index++,
                grouped: true,
              ),
            );
          }
      }
    }
    return SingleChildScrollView(
      padding: NativeSelectMetrics.listPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }

  Widget _option(
    LooseleafThemeData theme,
    NativeSelectOption<T> option,
    int index, {
    required bool grouped,
  }) {
    final chosen = option.value == value;
    final lit = index == highlighted && !option.disabled;
    const padding = NativeSelectMetrics.optionPadding;
    return Semantics(
      button: true,
      selected: chosen,
      enabled: !option.disabled,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: switch (option.disabled) {
          true => null,
          false => (_) => onHighlight(index),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: switch (option.disabled) {
            true => null,
            false => () => onSelect(index),
          },
          child: ColoredBox(
            color: switch (lit) {
              true => theme.colors.hiSelect,
              false => theme.colors.hiSelect.withValues(alpha: 0),
            },
            child: Padding(
              padding: switch (grouped) {
                true => padding.copyWith(start: padding.start * 2),
                false => padding,
              },
              child: InkContent(
                style: style.copyWith(
                  color: switch (option.disabled) {
                    true => theme.colors.pencilText,
                    false => theme.colors.ink,
                  },
                ),
                iconSize: NativeSelectMetrics.chevron,
                child: Row(
                  spacing: Spacing.d8,
                  children: [
                    Expanded(child: Text(option.label)),
                    if (chosen) const InkIcon('check'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
