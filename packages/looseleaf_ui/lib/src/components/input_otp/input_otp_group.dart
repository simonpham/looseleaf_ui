import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_metrics.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_scope.dart';

/// A run of [InputOTPSlot]s sitting close together. In a narrow row the
/// slots shrink evenly, down to their minimum width.
///
/// Mirrors `InputOTPGroup` in upstream `src/components/ui/input-otp.tsx`.
class InputOTPGroup extends StatelessWidget {
  const InputOTPGroup({super.key, required this.children});

  /// The slots.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final shrink = InputOTPScope.maybeOf(context)?.shrink ?? false;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: InputOTPMetrics.groupGap.of(context),
      children: [
        for (final child in children)
          switch (shrink) {
            true => Flexible(child: child),
            false => child,
          },
      ],
    );
  }
}
