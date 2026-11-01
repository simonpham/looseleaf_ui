import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CheckboxWithDescriptionExample extends StatefulWidget {
  const CheckboxWithDescriptionExample({super.key});

  @override
  State<CheckboxWithDescriptionExample> createState() =>
      _CheckboxWithDescriptionExampleState();
}

class _CheckboxWithDescriptionExampleState
    extends State<CheckboxWithDescriptionExample> {
  static const _maxWidth = 384.0;

  bool _terms = true;
  bool _policy = false;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldGroup(
      children: [
        Field(
          orientation: FieldOrientation.horizontal,
          children: [
            Checkbox(
              value: _terms,
              onChanged: (value) => setState(() => _terms = value),
              semanticLabel: 'Accept terms and conditions',
            ),
            FieldContent(
              children: [
                FieldLabel(
                  onPressed: () => setState(() => _terms = !_terms),
                  child: const Text('Accept terms and conditions'),
                ),
                const FieldDescription(
                  Text(
                    'By clicking this checkbox, you agree to the terms and conditions.',
                  ),
                ),
              ],
            ),
          ],
        ),
        Field(
          orientation: FieldOrientation.horizontal,
          children: [
            Checkbox(
              value: _policy,
              onChanged: (value) => setState(() => _policy = value),
              semanticLabel: 'Accept terms and conditions',
            ),
            FieldContent(
              children: [
                FieldLabel(
                  onPressed: () => setState(() => _policy = !_policy),
                  child: const Text('Accept terms and conditions'),
                ),
                const FieldDescription(
                  Text('You agree to our Terms of Service and Privacy Policy.'),
                ),
              ],
            ),
          ],
        ),
        const Field(
          orientation: FieldOrientation.horizontal,
          disabled: true,
          children: [
            Checkbox(
              value: false,
              disabled: true,
              semanticLabel: 'Enable notifications',
            ),
            FieldContent(
              children: [
                FieldLabel(child: Text('Enable notifications')),
                FieldDescription(Text('Switched off by your administrator.')),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
