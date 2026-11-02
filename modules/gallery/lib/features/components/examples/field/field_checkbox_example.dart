import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldCheckboxExample extends StatefulWidget {
  const FieldCheckboxExample({super.key});

  @override
  State<FieldCheckboxExample> createState() => _FieldCheckboxExampleState();
}

class _FieldCheckboxExampleState extends State<FieldCheckboxExample> {
  static const _maxWidth = Spacing.d448;
  static const _items = [
    'Hard disks',
    'External disks',
    'CDs, DVDs, and iPods',
    'Connected servers',
  ];

  final _shown = {'Hard disks'};
  var _sync = true;

  void _toggle(String item) => setState(() {
    if (_shown.remove(item)) return;
    _shown.add(item);
  });

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldGroup(
      children: [
        FieldSet(
          children: [
            const FieldLegend(
              Text('Show these items on the desktop'),
              variant: FieldLegendVariant.label,
            ),
            const FieldDescription(
              Text('Select the items you want to show on the desktop.'),
            ),
            FieldGroup(
              gap: Spacing.d12,
              children: [
                for (final item in _items)
                  Field(
                    orientation: FieldOrientation.horizontal,
                    children: [
                      Checkbox(
                        value: _shown.contains(item),
                        onChanged: (_) => _toggle(item),
                      ),
                      FieldLabel(
                        onPressed: () => _toggle(item),
                        child: Text(
                          item,
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        const FieldSeparator(),
        Field(
          orientation: FieldOrientation.horizontal,
          children: [
            Checkbox(
              value: _sync,
              onChanged: (value) => setState(() => _sync = value),
            ),
            FieldContent(
              children: [
                FieldLabel(
                  onPressed: () => setState(() => _sync = !_sync),
                  child: const Text('Sync Desktop & Documents folders'),
                ),
                const FieldDescription(
                  Text(
                    'Your Desktop & Documents folders are being synced with iCloud Drive. You can access them from other devices.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
