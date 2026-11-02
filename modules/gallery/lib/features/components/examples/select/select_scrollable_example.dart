import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SelectScrollableExample extends StatelessWidget {
  const SelectScrollableExample({super.key});

  @override
  Widget build(BuildContext context) => const Select(
    content: SelectContent(
      children: [
        SelectGroup(
          children: [
            SelectLabel(Text('North America')),
            SelectItem(
              value: 'est',
              child: Text('Eastern Standard Time (EST)'),
            ),
            SelectItem(
              value: 'cst',
              child: Text('Central Standard Time (CST)'),
            ),
            SelectItem(
              value: 'mst',
              child: Text('Mountain Standard Time (MST)'),
            ),
            SelectItem(
              value: 'pst',
              child: Text('Pacific Standard Time (PST)'),
            ),
            SelectItem(
              value: 'akst',
              child: Text('Alaska Standard Time (AKST)'),
            ),
            SelectItem(value: 'hst', child: Text('Hawaii Standard Time (HST)')),
          ],
        ),
        SelectGroup(
          children: [
            SelectLabel(Text('Europe & Africa')),
            SelectItem(value: 'gmt', child: Text('Greenwich Mean Time (GMT)')),
            SelectItem(
              value: 'cet',
              child: Text('Central European Time (CET)'),
            ),
            SelectItem(
              value: 'eet',
              child: Text('Eastern European Time (EET)'),
            ),
            SelectItem(
              value: 'west',
              child: Text('Western European Summer Time (WEST)'),
            ),
            SelectItem(value: 'cat', child: Text('Central Africa Time (CAT)')),
            SelectItem(value: 'eat', child: Text('East Africa Time (EAT)')),
          ],
        ),
        SelectGroup(
          children: [
            SelectLabel(Text('Asia')),
            SelectItem(value: 'msk', child: Text('Moscow Time (MSK)')),
            SelectItem(value: 'ist', child: Text('India Standard Time (IST)')),
            SelectItem(
              value: 'cst_china',
              child: Text('China Standard Time (CST)'),
            ),
            SelectItem(value: 'jst', child: Text('Japan Standard Time (JST)')),
            SelectItem(value: 'kst', child: Text('Korea Standard Time (KST)')),
            SelectItem(
              value: 'ist_indonesia',
              child: Text('Indonesia Central Standard Time (WITA)'),
            ),
          ],
        ),
        SelectGroup(
          children: [
            SelectLabel(Text('Australia & Pacific')),
            SelectItem(
              value: 'awst',
              child: Text('Australian Western Standard Time (AWST)'),
            ),
            SelectItem(
              value: 'acst',
              child: Text('Australian Central Standard Time (ACST)'),
            ),
            SelectItem(
              value: 'aest',
              child: Text('Australian Eastern Standard Time (AEST)'),
            ),
            SelectItem(
              value: 'nzst',
              child: Text('New Zealand Standard Time (NZST)'),
            ),
            SelectItem(value: 'fjt', child: Text('Fiji Time (FJT)')),
          ],
        ),
        SelectGroup(
          children: [
            SelectLabel(Text('South America')),
            SelectItem(value: 'art', child: Text('Argentina Time (ART)')),
            SelectItem(value: 'bot', child: Text('Bolivia Time (BOT)')),
            SelectItem(value: 'brt', child: Text('Brasilia Time (BRT)')),
            SelectItem(value: 'clt', child: Text('Chile Standard Time (CLT)')),
          ],
        ),
      ],
    ),
    child: SizedBox(
      width: Spacing.d256 + Spacing.d24,
      child: SelectTrigger(
        semanticLabel: 'Timezone',
        child: SelectValue(placeholder: 'Select a timezone'),
      ),
    ),
  );
}
