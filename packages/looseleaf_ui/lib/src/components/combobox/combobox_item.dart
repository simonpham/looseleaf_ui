import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_controller.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_row.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One choice in a [ComboboxList]. It hides when the search does not match
/// its label, [value] or [keywords]; the chosen row ends in a blue tick and
/// says "selected" to screen readers.
///
/// Mirrors `ComboboxItem` in upstream `src/components/ui/combobox.tsx`.
class ComboboxItem extends StatefulWidget {
  const ComboboxItem({
    super.key,
    required this.value,
    this.label,
    this.child,
    this.leading,
    this.keywords = const [],
    this.disabled = false,
    this.onSelect,
  });

  /// The value chosen.
  final String value;

  /// The text shown and searched; the root item's label, else [value].
  final String? label;

  /// Custom content over the label text.
  final Widget? child;

  /// An icon before the text.
  final Widget? leading;

  /// More words the search matches.
  final List<String> keywords;

  final bool disabled;

  /// Called when the row is chosen, before the combobox takes [value].
  final VoidCallback? onSelect;

  @override
  State<ComboboxItem> createState() => _ComboboxItemState();
}

class _ComboboxItemState extends State<ComboboxItem> {
  ComboboxController? _controller;
  ComboboxEntry? _entry;

  String _label(ComboboxController controller) =>
      widget.label ?? controller.labelFor(widget.value);

  void _choose(ComboboxController controller) {
    widget.onSelect?.call();
    controller.select(widget.value);
  }

  void _sync(ComboboxScope scope) {
    final controller = scope.controller;
    final entry = _entry;
    if (!identical(controller, _controller) ||
        entry == null ||
        entry.value != widget.value) {
      if (entry != null) _controller?.unregister(entry);
      _controller = controller;
      _entry = controller.register(
        value: widget.value,
        label: _label(controller),
        keywords: widget.keywords,
        disabled: widget.disabled,
        group: scope.group,
      );
      return;
    }
    entry
      ..label = _label(controller)
      ..keywords = widget.keywords
      ..disabled = widget.disabled
      ..group = scope.group;
  }

  @override
  void dispose() {
    if (_entry case final entry?) _controller?.unregister(entry);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ComboboxScope.of(context);
    _sync(scope);
    final controller = scope.controller;
    final entry = _entry;
    entry?.context = context;
    if (!controller.visible(widget.value)) return const SizedBox.shrink();
    final chosen = controller.value.contains(widget.value);
    final label = _label(controller);
    final colors = LooseleafTheme.of(context).colors;
    return Semantics(
      container: true,
      button: true,
      selected: chosen,
      enabled: !widget.disabled,
      label: label,
      onTap: switch (widget.disabled) {
        true => null,
        false => () => _choose(controller),
      },
      child: ExcludeSemantics(
        child: ComboboxRow(
          active: controller.active == widget.value,
          disabled: widget.disabled,
          leading: widget.leading,
          trailing: switch (chosen) {
            true => InkIcon('check', size: 16, color: colors.inkYou),
            false => null,
          },
          onHover: () => controller.highlight(widget.value),
          onTap: () => _choose(controller),
          child: widget.child ?? Text(label),
        ),
      ),
    );
  }
}
