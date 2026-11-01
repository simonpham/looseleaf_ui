import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One row of a [CommandList]: a hand-lettered line with an optional
/// [leading] icon and [trailing] [CommandShortcut]. It wears the
/// highlighter swipe while highlighted, is graphite when [disabled], and
/// hides when the search does not match its [value] or [keywords].
///
/// [value] defaults to the text of a [Text] [child]; give one when the
/// child is anything else.
///
/// Mirrors `CommandItem` in upstream `src/components/ui/command.tsx`.
class CommandItem extends StatefulWidget {
  const CommandItem({
    super.key,
    required this.child,
    this.value,
    this.keywords = const [],
    this.disabled = false,
    this.onSelect,
    this.leading,
    this.trailing,
  });

  /// The row's words.
  final Widget child;

  /// What the search matches and [onSelect] gets.
  final String? value;

  /// More words the search matches.
  final List<String> keywords;

  /// Graphite, skipped by the keys, not choosable.
  final bool disabled;

  /// Called with [value] on a tap or Enter.
  final ValueChanged<String>? onSelect;

  /// An icon before the words (16 px, soft ink).
  final Widget? leading;

  /// Something at the end, usually a [CommandShortcut].
  final Widget? trailing;

  @override
  State<CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<CommandItem> {
  CommandController? _controller;
  CommandEntry? _entry;
  late final String _fallback = 'command-item-${identityHashCode(this)}';

  String get _value => switch ((widget.value, widget.child)) {
    (final value?, _) => value,
    (null, Text(:final data?)) => data,
    _ => _fallback,
  };

  void _sync(CommandController controller, Object? group) {
    final entry = _entry;
    if (!identical(controller, _controller) || entry == null) {
      if (entry != null) _controller?.unregister(entry);
      _controller = controller;
      _entry = controller.register(
        CommandEntry(
          value: _value,
          keywords: widget.keywords,
          disabled: widget.disabled,
          group: group,
          onSelect: widget.onSelect,
        ),
      );
      return;
    }
    entry
      ..value = _value
      ..keywords = widget.keywords
      ..disabled = widget.disabled
      ..group = group
      ..onSelect = widget.onSelect;
  }

  @override
  void dispose() {
    if (_entry case final entry?) _controller?.unregister(entry);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    final group = context
        .dependOnInheritedWidgetOfExactType<CommandGroupScope>()
        ?.group;
    _sync(controller, group);
    _entry?.context = context;
    final value = _value;
    if (!controller.visible(value)) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    final disabled = widget.disabled;
    final active = controller.highlighted == value && !disabled;
    final color = switch ((disabled, active)) {
      (true, _) => theme.colors.pencilText,
      (false, true) => theme.colors.selectionText,
      (false, false) => theme.colors.ink,
    };
    final vertical = CommandMetrics.itemVertical.of(context);
    void choose() => controller.select(value);
    return Semantics(
      container: true,
      button: true,
      selected: active,
      enabled: !disabled,
      onTap: switch (disabled) {
        true => null,
        false => choose,
      },
      child: MouseRegion(
        onHover: switch (disabled) {
          true => null,
          false => (_) => controller.highlight(value),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: switch (disabled) {
            true => null,
            false => choose,
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: CommandMetrics.itemHeight.of(context),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: switch (active) {
                  true => theme.colors.hiSelect,
                  false => null,
                },
                borderRadius: CommandMetrics.swipe,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: CommandMetrics.itemInline,
                  vertical: vertical,
                ),
                child: InkContent(
                  style: CommandMetrics.text(theme, color: color),
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
                        ?widget.leading,
                        Expanded(child: widget.child),
                        ?widget.trailing,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
