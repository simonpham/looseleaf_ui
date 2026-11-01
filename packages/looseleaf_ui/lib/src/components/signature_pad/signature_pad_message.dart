import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The error under an invalid signature pad, in red script, announced as
/// it appears (upstream `role="alert"`).
///
/// Mirrors the alert of upstream `src/components/ui/signature-pad.tsx`.
class SignaturePadMessage extends StatelessWidget {
  const SignaturePadMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 20,
          cssLineHeight: 1,
          color: theme.colors.red,
        ),
      ),
    );
  }
}
