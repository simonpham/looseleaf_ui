import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_item.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_item_data.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds the row of one item.
typedef ComboboxItemBuilder =
    Widget Function(
      BuildContext context,
      ComboboxItemData item,
    );

/// The scrolling list of a [ComboboxContent]: at most 320 px tall, 4 px
/// inside. It shows [children], then a row per root item when built with
/// [itemBuilder] or [ComboboxList.items] (upstream's function children).
///
/// Mirrors `ComboboxList` in upstream `src/components/ui/combobox.tsx`.
class ComboboxList extends StatelessWidget {
  const ComboboxList({
    super.key,
    this.children = const [],
    this.itemBuilder,
    this.maxHeight = ComboboxMetrics.listMaxHeight,
  }) : _plainRows = false;

  /// A list with a plain [ComboboxItem] per root item, after [children].
  const ComboboxList.items({
    super.key,
    this.children = const [],
    this.maxHeight = ComboboxMetrics.listMaxHeight,
  }) : itemBuilder = null,
       _plainRows = true;

  /// Rows, groups, the empty state.
  final List<Widget> children;

  /// Builds a row per root item, after [children].
  final ComboboxItemBuilder? itemBuilder;

  final double maxHeight;

  final bool _plainRows;

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    final builder = itemBuilder;
    final generated = switch ((builder, _plainRows)) {
      (final build?, _) => [
        for (final item in controller.items) build(context, item),
      ],
      (null, true) => [
        for (final item in controller.items)
          ComboboxItem(
            key: ValueKey(item.value),
            value: item.value,
            label: item.label,
            keywords: item.keywords,
            disabled: item.disabled,
          ),
      ],
      (null, false) => const <Widget>[],
    };
    return Semantics(
      label: controller.label,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.d4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [...children, ...generated],
          ),
        ),
      ),
    );
  }
}
