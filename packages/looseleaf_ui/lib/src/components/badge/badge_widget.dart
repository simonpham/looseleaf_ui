import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/badge/badge.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A small label: a marker pill, a highlighter swipe, a red pill, an inked
/// outline, a ghost or a link, in three sizes.
///
/// Give it a [child], or a [count] that shows in tabular figures and stops
/// at `max+`. With [tally], counts from 1 to 20 are written as tally marks
/// (four uprights and a slash); screen readers still get the digits.
///
/// With [onPressed] the badge is a link or button (upstream `asChild` on an
/// `<a>`): it draws a hover layer, takes focus and answers Enter and Space.
///
/// ```dart
/// const Badge(child: Text('New'))
/// const Badge(count: 128, variant: BadgeVariant.destructive)
/// Badge(variant: BadgeVariant.link, onPressed: openDocs, child: Text('Docs'))
/// ```
///
/// Mirrors upstream `src/components/ui/badge.tsx`.
class Badge extends StatefulWidget {
  const Badge({
    super.key,
    this.child,
    this.variant = BadgeVariant.primary,
    this.size = BadgeSize.regular,
    this.tone,
    this.count,
    this.max = 99,
    this.tally = false,
    this.leading,
    this.onPressed,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The label, usually a [Text]; replaces [count]'s figures.
  final Widget? child;

  final BadgeVariant variant;
  final BadgeSize size;

  /// The marker color of a [BadgeVariant.primary] badge; marker when null.
  final BadgeTone? tone;

  /// A number to show: tabular figures, `max+` past [max].
  final int? count;

  /// The largest [count] shown as is.
  final int max;

  /// Writes [count] as tally marks when it is between 1 and 20.
  final bool tally;

  /// An icon before the label; tightens the start padding.
  final Widget? leading;

  /// Makes the badge a link or button, called on tap, Enter and Space.
  final VoidCallback? onPressed;

  /// Pins the hand: the same seed always draws the same badge.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name when the label is not text.
  final String? semanticLabel;

  /// States shown whatever the input, like upstream's `data-hover` and
  /// `data-focus-visible`: for state grids and goldens.
  final Set<InkState> forcedStates;

  /// Upstream `TALLY_MAX`: larger counts show as figures.
  static const int tallyMax = 20;

  @override
  State<Badge> createState() => _BadgeState();
}

class _BadgeState extends State<Badge> with InkSeed {
  int? get _tallied {
    final count = widget.count;
    if (!widget.tally || count == null) return null;
    if (count < 1 || count > Badge.tallyMax) return null;
    return count;
  }

  String? get _countText {
    final count = widget.count;
    if (count == null) return null;
    if (count > widget.max) return '${widget.max}+';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final hoverable = widget.onPressed != null;
    final params = BadgeParams(
      variant: widget.variant,
      size: widget.size,
      tone: widget.tone,
      tally: _tallied,
      hoverable: hoverable,
    );
    final source = RecipeInkSource(badgeRecipe, params, json: params.toJson());
    if (!hoverable) {
      return Semantics(
        container: true,
        label: widget.semanticLabel,
        child: _body(context, source, widget.forcedStates),
      );
    }
    return Semantics(
      container: true,
      button: true,
      label: widget.semanticLabel,
      child: InkInteraction(
        onActivate: widget.onPressed,
        states: widget.forcedStates,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: (context, states) => _body(context, source, states),
      ),
    );
  }

  Widget _body(BuildContext context, InkSource source, Set<InkState> states) {
    final theme = LooseleafTheme.of(context);
    final size = widget.size;
    final counted = widget.count != null;
    final padding = switch (counted) {
      true => Spacing.d6,
      false => size.padding,
    };
    final startPadding = switch (widget.leading) {
      null => padding,
      _ => size.iconPadding,
    };
    return InkContent(
      style: theme.typography
          .face(
            KevinSansFace.hand,
            cssSize: size.labelPx,
            cssLineHeight: 1,
            fontWeight: FontWeight.w700,
            color: widget.variant.label(
              theme.colors,
              hovered: states.contains(InkState.hovered),
            ),
          )
          .copyWith(
            fontFeatures: switch (counted) {
              true => const [
                FontFeature.tabularFigures(),
                FontFeature.liningFigures(),
              ],
              false => null,
            },
          ),
      iconSize: size.iconSize,
      wrap: false,
      child: InkSurface(
        source: source,
        seed: inkSeed(widget.seed),
        states: states,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: switch (counted) {
              true => Spacing.d24,
              false => 0,
            },
          ),
          child: SizedBox(
            height: size.height.of(context),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: startPadding,
                end: padding,
              ),
              child: Center(
                widthFactor: 1,
                child: _content(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    final children = [?widget.leading, ?_label()];
    if (children.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d4,
      children: children,
    );
  }

  Widget? _label() {
    if (_tallied case final tallied?) {
      return Semantics(
        label: _countText,
        child: SizedBox(
          width: badgeTallyWidth(tallied, widget.size.tallyHeight),
        ),
      );
    }
    if (widget.child case final child?) return Flexible(child: child);
    if (_countText case final text?) return Text(text);
    return null;
  }
}
