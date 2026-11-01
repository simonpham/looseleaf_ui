import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_button.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Something beside an [InputGroup]'s control: icons, [InputGroupText],
/// [InputGroupButton]s, in bold graphite 15 px Kevin Sans Hand.
///
/// [align] puts it before or after the control on its line, or on a full
/// line above or below. [border] draws a pencil rule along that edge of a
/// block addon, like upstream's `border-b` / `border-t`. Tapping it outside
/// its buttons focuses the control.
///
/// Mirrors `InputGroupAddon` in upstream `src/components/ui/input-group.tsx`.
class InputGroupAddon extends StatelessWidget {
  const InputGroupAddon({
    super.key,
    required this.child,
    this.align = InputGroupAlign.inlineStart,
    this.border,
  });

  /// The content; a [Row] when it holds several pieces.
  final Widget child;

  final InputGroupAlign align;

  /// A drawn rule on this edge of the addon.
  final InputGroupEdge? border;

  EdgeInsetsDirectional _padding(InputGroupScope? group) {
    final buttoned = child is InputGroupButton;
    final hasInput = group != null;
    return switch (align) {
      InputGroupAlign.inlineStart => EdgeInsetsDirectional.only(
        start: switch (buttoned) {
          true => Spacing.d4,
          false => Spacing.d12,
        },
        top: Spacing.d6,
        bottom: Spacing.d6,
      ),
      InputGroupAlign.inlineEnd => EdgeInsetsDirectional.only(
        end: switch (buttoned) {
          true => Spacing.d4,
          false => Spacing.d12,
        },
        top: Spacing.d6,
        bottom: Spacing.d6,
      ),
      InputGroupAlign.blockStart => EdgeInsetsDirectional.fromSTEB(
        Spacing.d12,
        switch (hasInput) {
          true => Spacing.d10,
          false => Spacing.d12,
        },
        Spacing.d12,
        switch (border) {
          InputGroupEdge.bottom => Spacing.d12,
          _ => Spacing.d6,
        },
      ),
      InputGroupAlign.blockEnd => EdgeInsetsDirectional.fromSTEB(
        Spacing.d12,
        switch (border) {
          InputGroupEdge.top => Spacing.d12,
          _ => Spacing.d6,
        },
        Spacing.d12,
        switch (hasInput) {
          true => Spacing.d10,
          false => Spacing.d12,
        },
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final group = InputGroupScope.maybeOf(context);
    final disabled = group?.disabled ?? false;
    final block =
        align == InputGroupAlign.blockStart ||
        align == InputGroupAlign.blockEnd;
    Widget addon = Padding(
      padding: _padding(group),
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 15,
          fontWeight: FontWeight.w700,
          color: switch (disabled) {
            true => theme.colors.pencilText,
            false => theme.colors.inkMuted,
          },
        ),
        iconSize: Spacing.d16,
        child: Align(
          alignment: switch (block) {
            true => AlignmentDirectional.centerStart,
            false => Alignment.center,
          },
          widthFactor: switch (block) {
            true => null,
            false => 1,
          },
          heightFactor: 1,
          child: child,
        ),
      ),
    );
    if (border case final edge?) {
      final params = InputGroupRuleParams(edge: edge);
      addon = InkSurface(
        source: RecipeInkSource(
          inputGroupRuleRecipe,
          params,
          json: params.toJson(),
        ),
        seed: 'input-group-rule|${edge.name}',
        still: true,
        child: addon,
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: switch ((group, disabled)) {
          (final scope?, false) => scope.focusNode.requestFocus,
          _ => null,
        },
        child: addon,
      ),
    );
  }
}
