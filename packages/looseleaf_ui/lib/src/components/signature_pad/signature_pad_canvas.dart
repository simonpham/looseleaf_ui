import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/signature_pad/signature_pad.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';

/// The signing surface: a [SketchpadCanvas] on a slip with a hairline
/// shadow, with the baseline, the sign-here cross, the typed signature and
/// the hint drawn under the ink ([SignaturePadGuides]).
///
/// Mirrors `SignaturePadCanvas` in upstream
/// `src/components/ui/signature-pad.tsx`.
class SignaturePadCanvas extends StatelessWidget {
  const SignaturePadCanvas({super.key, this.seed});

  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = SignaturePadScope.of(context);
    final typed = scope.typed.trim();
    final label = switch ((scope.mode, typed.isEmpty)) {
      (SignatureMode.draw, _) => null,
      (SignatureMode.type, true) => 'Signature, typed',
      (SignatureMode.type, false) => 'Signature, typed: $typed',
    };
    return SketchpadCanvas(
      label: 'Signature',
      semanticLabel: label,
      stock: StockName.slip,
      shadow: PaperShadow.hair,
      seed: seed,
      child: const SignaturePadGuides(),
    );
  }
}
