import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/prompt_input/prompt_input.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One choice in [PromptInputSuggestions]: highlighted under a highlighter
/// swipe when active (arrows or the pointer), picked by a tap, Enter or
/// Tab. Usually [onSelect] calls `PromptInputModel.replaceTrigger`.
///
/// Mirrors `PromptInputSuggestion` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputSuggestion extends StatelessWidget {
  const PromptInputSuggestion({
    super.key,
    required this.children,
    this.onSelect,
    this.disabled = false,
  });

  /// An icon, a name, a hint, 8 px apart.
  final List<Widget> children;

  final VoidCallback? onSelect;

  /// Graphite and not pickable.
  final bool disabled;

  /// `ll-swipe`'s radius, `3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius _swipe = BorderRadius.only(
    topLeft: Radius.elliptical(Spacing.d3, Spacing.d8),
    topRight: Radius.elliptical(Spacing.d8, Spacing.d3),
    bottomRight: Radius.elliptical(Spacing.d4, Spacing.d9),
    bottomLeft: Radius.elliptical(Spacing.d9, Spacing.d4),
  );

  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    final index = PromptInputSuggestionIndex.of(context);
    final active = !disabled && model.activeIndex == index;
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final row = DecoratedBox(
      decoration: BoxDecoration(
        color: switch (active) {
          true => colors.hiSelect,
          false => null,
        },
        borderRadius: _swipe,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d12,
          vertical: Spacing.d6,
        ),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 15,
            color: switch ((disabled, active)) {
              (true, _) => colors.pencilText,
              (false, true) => colors.selectionText,
              (false, false) => colors.ink,
            },
          ),
          child: Row(spacing: Spacing.d8, children: children),
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: active,
      enabled: !disabled,
      onTap: switch (disabled) {
        true => null,
        false => onSelect,
      },
      child: MouseRegion(
        cursor: switch (disabled) {
          true => SystemMouseCursors.forbidden,
          false => SystemMouseCursors.click,
        },
        onHover: (_) {
          if (!disabled) model.setActive(index);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: switch (disabled) {
            true => null,
            false => onSelect,
          },
          child: row,
        ),
      ),
    );
  }
}

/// A suggestion's position in its list.
class PromptInputSuggestionIndex extends InheritedWidget {
  const PromptInputSuggestionIndex({
    super.key,
    required this.index,
    required super.child,
  });

  final int index;

  /// The position of the enclosing suggestion; -1 outside a list.
  static int of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<PromptInputSuggestionIndex>()
          ?.index ??
      -1;

  @override
  bool updateShouldNotify(PromptInputSuggestionIndex oldWidget) =>
      oldWidget.index != index;
}
