import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_caret.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_metrics.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One box of an [InputOTP], showing the character at [index] in blue felt
/// script. The active box gets a blue ring and, while empty, a blinking
/// caret; a new character pops in.
///
/// Mirrors `InputOTPSlot` in upstream `src/components/ui/input-otp.tsx`.
class InputOTPSlot extends StatefulWidget {
  const InputOTPSlot({super.key, required this.index, this.seed});

  /// Which character of the code this box shows.
  final int index;

  /// Pins the hand.
  final String? seed;

  @override
  State<InputOTPSlot> createState() => _InputOTPSlotState();
}

class _InputOTPSlotState extends State<InputOTPSlot> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final scope = InputOTPScope.maybeOf(context);
    final index = widget.index;
    final char = scope?.charAt(index);
    final active = scope?.active == index;
    final disabled = scope?.disabled ?? false;
    final invalid = scope?.invalid ?? false;
    final params = OtpSlotParams(
      invalid: invalid,
      disabled: disabled,
      active: active,
      filled: char != null,
    );
    final style = theme.typography.face(
      KevinSansFace.script,
      cssSize: InputOTPMetrics.cssFontSize.resolve(theme.density),
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
      color: switch (disabled) {
        true => theme.colors.pencilText,
        false => theme.colors.inputInk,
      },
    );
    final placeholder = scope?.placeholderAt(index);
    final content = switch ((char, placeholder)) {
      (final typed?, _) => _Pop(
        key: ValueKey('$index|$typed'),
        animate: scope?.touched ?? false,
        child: Text(typed, style: style),
      ),
      (null, final hint?) => Text(
        hint,
        style: style.copyWith(color: theme.colors.placeholder),
      ),
      _ => null,
    };
    return ExcludeSemantics(
      child: InkSurface(
        source: RecipeInkSource(otpSlotRecipe, params, json: params.toJson()),
        seed: inkSeed(widget.seed),
        states: {
          if (disabled) InkState.disabled,
          if (invalid) InkState.invalid,
          if (active && !disabled) InkState.focused,
        },
        still: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: InputOTPMetrics.slotMinWidth,
            maxWidth: InputOTPMetrics.slotWidth.resolve(theme.density),
          ),
          child: SizedBox(
            width: double.infinity,
            height: InputOTPMetrics.slotHeight.resolve(theme.density),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ?content,
                if (active && char == null && !disabled) const InputOTPCaret(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pop extends StatelessWidget {
  const _Pop({super.key, required this.animate, required this.child});

  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: InkMotion.popScale, end: 1),
      duration: InkMotion.of(context, InkMotion.pop),
      curve: InkMotion.popCurve,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
