import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_metrics.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The hand-drawn I-beam in an empty active [InputOTPSlot], blinking on for
/// 55% of each 1.1 s (`ll-otp-blink`), still under reduced motion.
///
/// Mirrors the `[data-part=caret]` rules of upstream `otpCss`
/// (`src/lib/ink/recipes/input-otp-ink.ts`).
class InputOTPCaret extends StatefulWidget {
  const InputOTPCaret({super.key});

  @override
  State<InputOTPCaret> createState() => _InputOTPCaretState();
}

class _InputOTPCaretState extends State<InputOTPCaret>
    with SingleTickerProviderStateMixin {
  static const Duration _period = Duration(milliseconds: 1100);
  static const double _on = 0.55;

  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: _period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (InkMotion.reducedIn(context)) {
      _blink.stop();
      _blink.value = 0;
      return;
    }
    if (!_blink.isAnimating) _blink.repeat();
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _blink,
      builder: (context, child) => Opacity(
        opacity: switch (_blink.value <= _on) {
          true => 1,
          false => 0,
        },
        child: child,
      ),
      child: InkArt(
        cacheKey: 'otp|caret',
        draw: () => otpCaret('otp|caret'),
        size: const Size(
          InputOTPMetrics.caretWidth,
          InputOTPMetrics.caretHeight,
        ),
        color: LooseleafTheme.of(context).colors.caret,
      ),
    ),
  );
}
