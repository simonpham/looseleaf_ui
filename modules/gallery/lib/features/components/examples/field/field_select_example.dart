import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldSelectExample extends StatefulWidget {
  const FieldSelectExample({super.key});

  @override
  State<FieldSelectExample> createState() => _FieldSelectExampleState();
}

class _FieldSelectExampleState extends State<FieldSelectExample> {
  static const _maxWidth = 448.0;
  static const _departments = {
    'engineering': 'Engineering',
    'design': 'Design',
    'marketing': 'Marketing',
    'sales': 'Sales',
    'support': 'Customer Support',
    'hr': 'Human Resources',
    'finance': 'Finance',
    'operations': 'Operations',
  };

  var _open = false;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Field(
      children: [
        FieldLabel(
          onPressed: () => setState(() => _open = true),
          child: const Text('Department'),
        ),
        Select(
          open: _open,
          onOpenChange: (open) => setState(() => _open = open),
          content: SelectContent(
            children: [
              for (final MapEntry(:key, :value) in _departments.entries)
                SelectItem(value: key, child: Text(value)),
            ],
          ),
          child: const SelectTrigger(
            child: SelectValue(placeholder: 'Choose department'),
          ),
        ),
        const FieldDescription(
          Text('Select your department or area of work.'),
        ),
      ],
    ),
  );
}
