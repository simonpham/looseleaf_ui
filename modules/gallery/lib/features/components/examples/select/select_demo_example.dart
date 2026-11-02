import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SelectDemoExample extends StatelessWidget {
  const SelectDemoExample({super.key});

  @override
  Widget build(BuildContext context) => const Select(
    content: SelectContent(
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
      width: Spacing.d176 + Spacing.d4,
      child: SelectTrigger(
        semanticLabel: 'Fruit',
        child: SelectValue(placeholder: 'Select a fruit'),
      ),
    ),
  );
}
