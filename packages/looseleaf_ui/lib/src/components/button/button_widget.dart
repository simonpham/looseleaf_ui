import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The thing you press: a marker-filled primary, a solid red destructive, an
/// inked outline, a highlighter secondary, a whisper-box ghost or a
/// hand-underlined link, in every shadcn size.
///
/// The label is Kevin Sans Hand in bold; the drawing sits behind it, sized
/// to the button. Hover tilts the drawing, pressing sinks the button by a
/// pixel, keyboard focus draws a blue felt ring.
///
/// ```dart
/// Button(onPressed: save, child: const Text('Save changes'))
/// Button(
///   variant: ButtonVariant.outline,
///   size: ButtonSize.icon,
///   semanticLabel: 'Search',
///   onPressed: search,
///   child: const Icon(searchIcon),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/button.tsx`.
class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.regular,
    this.shape = ButtonShape.standard,
    this.disabled = false,
    this.leading,
    this.trailing,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The label, usually a [Text]; the icon for the icon sizes.
  final Widget child;

  /// Called on tap, Enter and Space. A null callback does not disable the
  /// button; [disabled] does.
  final VoidCallback? onPressed;

  final ButtonVariant variant;
  final ButtonSize size;

  /// [ButtonShape.pill] is upstream's `rounded-full`: half-height corners, a
  /// hand-drawn circle on a square icon button.
  final ButtonShape shape;

  /// A dashed pencil box on a pale wash, a pencil label, no input, out of
  /// the tab order.
  final bool disabled;

  /// An icon before the label; tightens the inline padding.
  final Widget? leading;

  /// An icon after the label; tightens the inline padding.
  final Widget? trailing;

  /// Pins the hand: the same seed always draws the same button.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, like upstream's `data-hover`,
  /// `data-pressed` and `data-focus-visible`: for state grids and goldens.
  final Set<InkState> forcedStates;

  /// The accessible name, for icon buttons whose child is not text.
  final String? semanticLabel;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = ButtonParams(
      variant: widget.variant,
      size: widget.size,
      disabled: widget.disabled,
      shape: widget.shape,
    );
    final source = RecipeInkSource(
      buttonRecipe,
      params,
      json: params.toJson(),
    );
    return Semantics(
      container: true,
      button: true,
      enabled: !widget.disabled,
      label: widget.semanticLabel,
      child: InkInteraction(
        enabled: !widget.disabled,
        onActivate: widget.onPressed,
        states: widget.forcedStates,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: (context, states) => _body(context, source, states),
      ),
    );
  }

  Widget _body(BuildContext context, InkSource source, Set<InkState> states) {
    final button = widget;
    final theme = LooseleafTheme.of(context);
    final size = button.size;
    final pressed = states.contains(InkState.pressed);
    final label = button.variant.label(
      theme.colors,
      disabled: button.disabled,
      hovered: states.contains(InkState.hovered),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(
        end: switch (pressed) {
          true => InkMotion.pressSink,
          false => 0,
        },
      ),
      duration: InkMotion.of(context, InkMotion.press),
      curve: InkMotion.easeOut,
      builder: (context, sink, child) =>
          Transform.translate(offset: Offset(0, sink), child: child),
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: size.cssFontSize,
          cssLineHeight: size.cssLineHeight,
          fontWeight: FontWeight.w700,
          color: label,
        ),
        iconSize: size.iconSize,
        wrap: false,
        child: InkSurface(
          source: source,
          seed: inkSeed(button.seed),
          states: states,
          sinkSelf: true,
          swipeOnHover: switch (button.variant) {
            ButtonVariant.ghost || ButtonVariant.link => true,
            _ => false,
          },
          child: _content(size.height.resolve(theme.density)),
        ),
      ),
    );
  }

  Widget _content(double height) {
    final button = widget;
    final size = button.size;
    if (size.isIcon) {
      return SizedBox.square(
        dimension: height,
        child: Center(child: button.child),
      );
    }
    final withIcon = button.leading != null || button.trailing != null;
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.padding(withIcon: withIcon),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: size.gap,
          children: [
            ?button.leading,
            Flexible(child: button.child),
            ?button.trailing,
          ],
        ),
      ),
    );
  }
}
