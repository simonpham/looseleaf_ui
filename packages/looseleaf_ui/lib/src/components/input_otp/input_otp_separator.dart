import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_metrics.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A drawn dash between [InputOTPGroup]s.
///
/// Mirrors `InputOTPSeparator` in upstream
/// `src/components/ui/input-otp.tsx`.
class InputOTPSeparator extends StatelessWidget {
  const InputOTPSeparator({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: InkIcon(
      'minus',
      size: InputOTPMetrics.separatorIcon,
      color: LooseleafTheme.of(context).colors.inkSoft,
    ),
  );
}
