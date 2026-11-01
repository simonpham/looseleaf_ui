import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/rating/rating_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One glyph of a [Rating]: the drawn star, heart or sun at [index], and
/// over it the radio (two with `allowHalf`, one over each half) that
/// chooses its value. Filled when the shown value reaches [index], half
/// filled when it reaches `index - 0.5`.
///
/// A [Rating] builds these itself; pass your own as its `children` to
/// style or space them.
///
/// Mirrors `RatingItem` in upstream `src/components/ui/rating.tsx`.
class RatingItem extends StatefulWidget {
  const RatingItem({super.key, required this.index});

  /// The glyph's position, from 1.
  final int index;

  @override
  State<RatingItem> createState() => _RatingItemState();
}

class _RatingItemState extends State<RatingItem> {
  static const double _hoverScale = 1.1;
  static const EdgeInsets _slop = EdgeInsets.all(Spacing.d2);

  final Set<double> _focusVisible = {};
  bool _hovered = false;

  void _onFocusHighlight(double value, bool visible) {
    setState(() {
      if (visible) {
        _focusVisible.add(value);
        return;
      }
      _focusVisible.remove(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = RatingScope.of(context);
    final index = widget.index;
    final checked = scope.shown >= index;
    final half = !checked && scope.allowHalf && scope.shown >= index - 0.5;
    final params = RatingParams(
      icon: scope.icon,
      disabled: scope.disabled,
      invalid: scope.invalid,
    );
    final glyph = SizedBox.square(
      dimension: scope.size.glyph,
      child: InkSurface(
        source: RecipeInkSource(ratingRecipe, params, json: params.toJson()),
        seed: '${scope.seed}:$index',
        still: true,
        states: {
          if (checked) InkState.checked,
          if (half) InkState.indeterminate,
          if (_focusVisible.isNotEmpty) InkState.focused,
        },
      ),
    );
    final grown = scope.interactive && _hovered;
    final scaled = AnimatedScale(
      scale: switch (grown) {
        true => _hoverScale,
        false => 1,
      },
      duration: InkMotion.of(context, InkMotion.pop),
      curve: InkMotion.popCurve,
      child: glyph,
    );
    if (scope.readOnly) return ExcludeSemantics(child: scaled);
    final values = switch (scope.allowHalf) {
      true => [index - 0.5, index.toDouble()],
      false => [index.toDouble()],
    };
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkHitArea(
        slop: _slop,
        child: Stack(
          children: [
            scaled,
            Positioned.fill(
              child: Row(
                children: [
                  for (final value in values)
                    Expanded(
                      child: _RatingRadio(
                        value: value,
                        scope: scope,
                        onFocusHighlight: (visible) =>
                            _onFocusHighlight(value, visible),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingRadio extends StatelessWidget {
  const _RatingRadio({
    required this.value,
    required this.scope,
    required this.onFocusHighlight,
  });

  final double value;
  final RatingScope scope;
  final ValueChanged<bool> onFocusHighlight;

  @override
  Widget build(BuildContext context) {
    final enabled = !scope.disabled;
    void choose() => scope.select(value);
    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: scope.current == value,
      enabled: enabled,
      label: scope.label(value, scope.max),
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: scope.focusNodeFor(value),
        shortcuts: InkActivation.button.shortcuts,
        actions: InkActivation.button.actions(choose),
        onShowFocusHighlight: onFocusHighlight,
        mouseCursor: switch (enabled) {
          true => SystemMouseCursors.click,
          false => SystemMouseCursors.forbidden,
        },
        child: MouseRegion(
          onEnter: (_) {
            if (enabled) scope.preview(value);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: !enabled,
            onTap: switch (enabled) {
              true => choose,
              false => null,
            },
          ),
        ),
      ),
    );
  }
}
