import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SignaturePadAgreementFormExample extends StatefulWidget {
  const SignaturePadAgreementFormExample({super.key});

  @override
  State<SignaturePadAgreementFormExample> createState() =>
      _SignaturePadAgreementFormExampleState();
}

class _SignaturePadAgreementFormExampleState
    extends State<SignaturePadAgreementFormExample> {
  static const _maxWidth = Spacing.d512;
  static final _thousands = RegExp(r'\B(?=(\d{3})+(?!\d))');

  final GlobalKey<FormState> _form = GlobalKey();
  String _signature = '';
  String? _sent;

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final length = '${_signature.length}'.replaceAll(_thousands, ',');
    setState(() => _sent = '$length characters of image');
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Form(
        key: _form,
        child: Card(
          tilt: false,
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Studio rental agreement')),
                CardDescription(Text('Three hours, one kettle, no glitter.')),
              ],
            ),
            CardContent(
              padding: const EdgeInsets.fromLTRB(
                Spacing.d24,
                Spacing.d16,
                Spacing.d24,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d16,
                children: [
                  FormField<bool>(
                    initialValue: false,
                    validator: (promised) => switch (promised) {
                      true => null,
                      _ => 'Promise first.',
                    },
                    builder: (field) => Row(
                      spacing: Spacing.d8,
                      children: [
                        Checkbox(
                          value: field.value ?? false,
                          invalid: field.hasError,
                          semanticLabel: 'I promise, no glitter',
                          onChanged: field.didChange,
                        ),
                        Label(
                          onPressed: () =>
                              field.didChange(!(field.value ?? false)),
                          child: const Text('I promise, no glitter'),
                        ),
                      ],
                    ),
                  ),
                  SignaturePad(
                    required: true,
                    penColor: SketchColor.inkYou,
                    onChanged: (value, _) => _signature = value,
                  ),
                ],
              ),
            ),
            CardFooter(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: Spacing.d12,
              padding: const EdgeInsets.fromLTRB(
                Spacing.d24,
                Spacing.d16,
                Spacing.d24,
                0,
              ),
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _sent ?? 'Not sent yet',
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
                  ),
                ),
                Button(
                  onPressed: _submit,
                  child: const Text('Sign and send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
