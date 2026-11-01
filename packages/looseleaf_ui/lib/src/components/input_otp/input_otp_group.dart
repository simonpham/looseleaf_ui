import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_metrics.dart';

/// A run of [InputOTPSlot]s sitting close together.
///
/// Mirrors `InputOTPGroup` in upstream `src/components/ui/input-otp.tsx`.
class InputOTPGroup extends StatelessWidget {
  const InputOTPGroup({super.key, required this.children});

  /// The slots.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: InputOTPMetrics.groupGap.of(context),
    children: children,
  );
}
