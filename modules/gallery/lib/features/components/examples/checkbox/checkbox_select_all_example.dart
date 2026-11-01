import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CheckboxSelectAllExample extends StatefulWidget {
  const CheckboxSelectAllExample({super.key});

  @override
  State<CheckboxSelectAllExample> createState() =>
      _CheckboxSelectAllExampleState();
}

class _CheckboxSelectAllExampleState extends State<CheckboxSelectAllExample> {
  static const _items = [
    'Pencils',
    'Highlighters',
    'Washi tape',
    'Index cards',
  ];

  final _picked = <String>{'Pencils'};

  bool? get _all => switch (_picked.length) {
    0 => false,
    final count when count == _items.length => true,
    _ => null,
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d12,
    children: [
      Checkbox(
        value: _all,
        onChanged: (value) => setState(() {
          _picked.clear();
          if (value) _picked.addAll(_items);
        }),
        label: const Text('Everything on the desk'),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.only(start: Spacing.d28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d12,
          children: [
            for (final item in _items)
              Checkbox(
                value: _picked.contains(item),
                onChanged: (value) => setState(() {
                  if (value) {
                    _picked.add(item);
                    return;
                  }
                  _picked.remove(item);
                }),
                label: Text(item),
              ),
          ],
        ),
      ),
    ],
  );
}
