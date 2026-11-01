import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show
        MarkerRuleParams,
        MarkerSide,
        MarkerStyle,
        MarkerTone,
        markerRuleRecipe;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/marker/marker_content.dart';
import 'package:looseleaf_ui/src/components/marker/marker_scope.dart';
import 'package:looseleaf_ui/src/components/marker/marker_variant.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A small hand-written marker in a stream of messages or events: a day
/// between pencil rules, a section heading over a rule, or small print
/// after an icon. Put a [MarkerIcon] and a [MarkerContent] in [children].
///
/// `tone: .fresh` draws the rules in red pencil and the words on a
/// highlighter swipe ("New messages"). With [onPressed] the whole marker is
/// a button named [semanticLabel].
///
/// ```dart
/// Marker(
///   variant: .separator,
///   children: [MarkerContent(child: Text('Today'))],
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/marker.tsx`.
class Marker extends StatelessWidget {
  const Marker({
    super.key,
    required this.children,
    this.variant = MarkerVariant.regular,
    this.tone = MarkerTone.regular,
    this.rule = MarkerStyle.line,
    this.seed,
    this.onPressed,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  final List<Widget> children;
  final MarkerVariant variant;
  final MarkerTone tone;

  /// The border rule's stroke; only [MarkerVariant.border] reads it.
  final MarkerStyle rule;

  /// Pins the hand: the same seed always draws the same rules.
  final String? seed;

  /// Makes the marker a button (upstream `asChild` on a `<button>`).
  final VoidCallback? onPressed;

  /// The button's accessible name.
  final String? semanticLabel;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final body = MarkerScope(
      variant: variant,
      tone: tone,
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          color: theme.colors.inkMuted,
        ),
        iconSize: Spacing.d16,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.d16),
          child: _layout(),
        ),
      ),
    );
    final pressed = onPressed;
    if (pressed == null) return body;
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      child: InkInteraction(
        onActivate: pressed,
        states: forcedStates,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (context, states) => body,
      ),
    );
  }

  Widget _layout() {
    final separator = variant == MarkerVariant.separator;
    final row = Row(
      spacing: Spacing.d8,
      children: [
        if (separator) Expanded(child: _rule(MarkerSide.start)),
        for (final child in children)
          switch ((child, separator)) {
            (MarkerContent(), false) => Flexible(child: child),
            _ => child,
          },
        if (separator) Expanded(child: _rule(MarkerSide.end)),
      ],
    );
    if (variant != MarkerVariant.border) return row;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.d12),
          child: row,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: Spacing.d16,
          child: _rule(
            MarkerSide.full,
            style: rule,
          ),
        ),
      ],
    );
  }

  Widget _rule(MarkerSide side, {MarkerStyle style = MarkerStyle.line}) =>
      _MarkerRule(
        side: side,
        tone: tone,
        style: style,
        seed: seed,
      );
}

class _MarkerRule extends StatefulWidget {
  const _MarkerRule({
    required this.side,
    required this.tone,
    required this.style,
    this.seed,
  });

  final MarkerSide side;
  final MarkerTone tone;
  final MarkerStyle style;
  final String? seed;

  @override
  State<_MarkerRule> createState() => _MarkerRuleState();
}

class _MarkerRuleState extends State<_MarkerRule> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = MarkerRuleParams(
      side: widget.side,
      tone: widget.tone,
      style: widget.style,
    );
    final seed = switch (widget.seed) {
      final String pinned => '$pinned|${widget.side.name}',
      null => inkSeed(null),
    };
    return ExcludeSemantics(
      child: InkSurface(
        source: RecipeInkSource(
          markerRuleRecipe,
          params,
          json: params.toJson(),
        ),
        seed: seed,
        still: true,
        child: const SizedBox(height: Spacing.d16),
      ),
    );
  }
}
