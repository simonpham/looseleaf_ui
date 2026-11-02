import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupInAFieldExample extends StatefulWidget {
  const ToggleGroupInAFieldExample({super.key});

  @override
  State<ToggleGroupInAFieldExample> createState() =>
      _ToggleGroupInAFieldExampleState();
}

class _ToggleGroupInAFieldExampleState
    extends State<ToggleGroupInAFieldExample> {
  static const _days = [
    ('mon', 'M', 'Monday'),
    ('tue', 'T', 'Tuesday'),
    ('wed', 'W', 'Wednesday'),
    ('thu', 'T', 'Thursday'),
    ('fri', 'F', 'Friday'),
    ('sat', 'S', 'Saturday'),
    ('sun', 'S', 'Sunday'),
  ];
  static const _maxWidth = 384.0;

  var _picked = <String>{};

  @override
  Widget build(BuildContext context) {
    final invalid = _picked.isEmpty;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Field(
        invalid: invalid,
        children: [
          const FieldLabel(child: Text('Quiet days')),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ToggleGroup<String>(
              type: ToggleGroupType.multiple,
              variant: ToggleVariant.outline,
              invalid: invalid,
              value: _picked,
              onChanged: (value) => setState(() => _picked = value),
              semanticLabel: 'Quiet days',
              children: [
                for (final (id, short, label) in _days)
                  ToggleGroupItem(
                    value: id,
                    semanticLabel: label,
                    child: Text(short),
                  ),
              ],
            ),
          ),
          const FieldDescription(Text('No notifications on these days.')),
          if (invalid)
            const FieldError(child: Text('Choose at least one day.')),
        ],
      ),
    );
  }
}
