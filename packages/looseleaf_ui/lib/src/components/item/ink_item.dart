import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/item/item.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row of a list: [ItemMedia], [ItemContent] (taking the room left) and
/// [ItemActions] side by side, with [ItemHeader] and [ItemFooter] on lines
/// of their own. Bare, outlined in ruled pencil, or washed in paper-shade;
/// no drawing is needed, the pencil is tiled.
///
/// With [onPressed] the row is a link: pointing at it lights it up under a
/// highlighter swipe, the keyboard gives it a blue focus ring, and Enter or
/// Space activates it. In an [ItemGroup] it is a list item.
///
/// ```dart
/// InkItem(
///   variant: ItemVariant.outline,
///   children: [
///     ItemMedia(variant: ItemMediaVariant.icon, child: InkIcon('user')),
///     ItemContent(children: [
///       ItemTitle(Text('Profile')),
///       ItemDescription(Text('Your name, your face, your pencil case.')),
///     ]),
///     ItemActions(children: [Button(size: ButtonSize.sm, child: Text('Open'))]),
///   ],
/// )
/// ```
///
/// Mirrors `InkItem` in upstream `src/components/ui/item.tsx`.
class InkItem extends StatefulWidget {
  const InkItem({
    super.key,
    required this.children,
    this.variant = ItemVariant.regular,
    this.size = ItemSize.regular,
    this.onPressed,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// Media, content, actions, a header and a footer.
  final List<Widget> children;

  final ItemVariant variant;
  final ItemSize size;

  /// Makes the row a link, upstream's `asChild` anchor or button.
  final VoidCallback? onPressed;

  /// Picks the pencil frame.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The row's accessible name, when its text is not enough.
  final String? semanticLabel;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  State<InkItem> createState() => _InkItemState();
}

class _InkItemState extends State<InkItem> with InkSeed {
  static const _outlineOpacity = 0.8;
  static const _ruleOpacity = 0.85;
  static const _mutedAlpha = 0.65;

  bool get _described => widget.children.any(
    (child) =>
        child is ItemContent &&
        child.children.any((part) => part is ItemDescription),
  );

  @override
  Widget build(BuildContext context) {
    final scope = ItemScope.maybeOf(context);
    final row = switch (widget.onPressed) {
      null => _row(context, const {}),
      final onPressed => InkInteraction(
        onActivate: onPressed,
        states: widget.forcedStates,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: _row,
      ),
    };
    return Semantics(
      container: true,
      role: switch (scope) {
        null => null,
        _ => SemanticsRole.listItem,
      },
      button: widget.onPressed != null,
      label: widget.semanticLabel,
      child: row,
    );
  }

  Widget _row(BuildContext context, Set<InkState> states) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final frame = ItemFrame.of(inkSeed(widget.seed));
    final hovered = states.contains(InkState.hovered);
    Widget row = ItemRowScope(
      described: _described,
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 15,
          color: switch (hovered) {
            true => colors.selectionText,
            false => colors.ink,
          },
        ),
        child: Padding(
          padding: widget.size.padding(theme.density),
          child: _lines(),
        ),
      ),
    );
    row = switch (widget.variant) {
      ItemVariant.regular => row,
      ItemVariant.outline => CustomPaint(
        painter: ItemPainter(
          frame: frame,
          kind: ItemPaint.outline,
          color: colors.pencil,
          opacity: _outlineOpacity,
          theme: theme,
        ),
        child: row,
      ),
      ItemVariant.muted => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.paperShade.withValues(
            alpha: colors.paperShade.a * _mutedAlpha,
          ),
          borderRadius: ItemMetrics.muted,
        ),
        child: row,
      ),
    };
    if (hovered) {
      row = DecoratedBox(
        decoration: BoxDecoration(
          color: colors.hiSelect,
          borderRadius: ItemMetrics.swipe,
        ),
        child: row,
      );
    }
    if (ItemScope.maybeOf(context)?.ruled ?? false) {
      row = CustomPaint(
        painter: ItemPainter(
          frame: frame,
          kind: ItemPaint.rule,
          color: colors.ruleBlue,
          opacity: _ruleOpacity,
          theme: theme,
        ),
        child: row,
      );
    }
    if (!states.contains(InkState.focused)) return row;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        row,
        Positioned.fill(
          left: -Spacing.d4,
          top: -Spacing.d4,
          right: -Spacing.d4,
          bottom: -Spacing.d4,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colors.focus, width: Spacing.d2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// `flex flex-wrap items-center`: header and footer take whole lines
  /// (`basis-full`), the rest share one.
  Widget _lines() {
    final gap = widget.size.gap;
    final header = [
      for (final child in widget.children)
        if (child is ItemHeader) child,
    ];
    final footer = [
      for (final child in widget.children)
        if (child is ItemFooter) child,
    ];
    final inline = [
      for (final child in widget.children)
        if (child is! ItemHeader && child is! ItemFooter) child,
    ];
    final described = _described;
    var filled = false;
    final cells = <Widget>[];
    for (final child in inline) {
      if (child is ItemContent && !filled) {
        filled = true;
        cells.add(
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: child,
            ),
          ),
        );
        continue;
      }
      final top = child is ItemMedia && described;
      cells.add(
        Align(
          widthFactor: 1,
          alignment: switch (top) {
            true => Alignment.topCenter,
            false => Alignment.center,
          },
          child: child,
        ),
      );
    }
    final line = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: cells,
      ),
    );
    if (header.isEmpty && footer.isEmpty) return line;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [...header, if (inline.isNotEmpty) line, ...footer],
    );
  }
}
