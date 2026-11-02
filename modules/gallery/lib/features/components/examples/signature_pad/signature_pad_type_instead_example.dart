import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SignaturePadTypeInsteadExample extends StatelessWidget {
  const SignaturePadTypeInsteadExample({super.key});

  static const _maxWidth = Spacing.d512;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const SignaturePad(initialMode: SignatureMode.type),
    ),
  );
}
