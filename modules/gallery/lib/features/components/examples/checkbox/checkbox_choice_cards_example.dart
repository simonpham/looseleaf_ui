import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CheckboxChoiceCardsExample extends StatefulWidget {
  const CheckboxChoiceCardsExample({super.key});

  @override
  State<CheckboxChoiceCardsExample> createState() =>
      _CheckboxChoiceCardsExampleState();
}

class _CheckboxChoiceCardsExampleState
    extends State<CheckboxChoiceCardsExample> {
  static const _maxWidth = 384.0;

  bool _notify = true;
  bool _digest = false;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldGroup(
      children: [
        FieldLabel(
          checked: _notify,
          onPressed: () => setState(() => _notify = !_notify),
          child: Field(
            orientation: FieldOrientation.horizontal,
            children: [
              Checkbox(
                value: _notify,
                onChanged: (value) => setState(() => _notify = value),
                semanticLabel: 'Enable notifications',
              ),
              const FieldContent(
                children: [
                  FieldTitle(Text('Enable notifications')),
                  FieldDescription(
                    Text(
                      'You can enable or disable notifications at any time.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        FieldLabel(
          checked: _digest,
          onPressed: () => setState(() => _digest = !_digest),
          child: Field(
            orientation: FieldOrientation.horizontal,
            children: [
              Checkbox(
                value: _digest,
                onChanged: (value) => setState(() => _digest = value),
                semanticLabel: 'Weekly digest',
              ),
              const FieldContent(
                children: [
                  FieldTitle(Text('Weekly digest')),
                  FieldDescription(
                    Text('One email on Friday with everything you missed.'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
