import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SelectDefaultExample extends StatelessWidget {
  const SelectDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Select(
    content: SelectContent(
      position: SelectPosition.popper,
      children: [
        SelectGroup(
          children: [
            SelectLabel(Text('Fruits')),
            SelectItem(value: 'apple', child: Text('Apple')),
            SelectItem(value: 'banana', child: Text('Banana')),
            SelectItem(value: 'blueberry', child: Text('Blueberry')),
            SelectItem(value: 'grapes', child: Text('Grapes')),
            SelectItem(value: 'pineapple', child: Text('Pineapple')),
          ],
        ),
      ],
    ),
    child: SizedBox(
      width: Spacing.d176 + Spacing.d14,
      child: SelectTrigger(
        semanticLabel: 'Fruit',
        child: SelectValue(placeholder: 'Pick a fruit'),
      ),
    ),
  );
}
