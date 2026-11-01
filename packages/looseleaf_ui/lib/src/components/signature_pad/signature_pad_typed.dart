import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/components/signature_pad/signature_pad.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The name field of the typed signature, shown only while typing; the
/// name is lettered on the pad as you type.
///
/// Mirrors `SignaturePadTyped` in upstream
/// `src/components/ui/signature-pad.tsx`.
class SignaturePadTyped extends StatelessWidget {
  const SignaturePadTyped({
    super.key,
    this.placeholder = 'Type your full name',
    this.autofocus = false,
    this.seed,
  });

  final String placeholder;
  final bool autofocus;
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = SignaturePadScope.of(context);
    if (scope.mode != SignatureMode.type) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d4),
      child: Input(
        controller: scope.typedController,
        focusNode: scope.typedFocusNode,
        placeholder: placeholder,
        semanticLabel: 'Type your full name',
        autofillHints: const [AutofillHints.name],
        disabled: scope.disabled,
        autofocus: autofocus,
        seed: seed,
      ),
    );
  }
}
