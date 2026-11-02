import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SelectGroupsExample extends StatelessWidget {
  const SelectGroupsExample({super.key});

  static const _zones = [
    (
      'North America',
      [
        'Eastern (EST)',
        'Central (CST)',
        'Mountain (MST)',
        'Pacific (PST)',
        'Alaska (AKST)',
        'Hawaii (HST)',
      ],
    ),
    (
      'Europe & Africa',
      [
        'Greenwich Mean (GMT)',
        'Central European (CET)',
        'Eastern European (EET)',
        'West Africa (WAT)',
        'Central Africa (CAT)',
        'East Africa (EAT)',
      ],
    ),
    (
      'Asia',
      [
        'Moscow (MSK)',
        'India (IST)',
        'China (CST)',
        'Japan (JST)',
        'Korea (KST)',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => Select(
    defaultValue: 'Central European (CET)',
    content: SelectContent(
      maxHeight: Spacing.d288,
      children: [
        for (final (index, (region, zones)) in _zones.indexed)
          SelectGroup(
            children: [
              if (index > 0) const SelectSeparator(),
              SelectLabel(Text(region)),
              for (final zone in zones)
                SelectItem(value: zone, child: Text(zone)),
            ],
          ),
      ],
    ),
    child: const SizedBox(
      width: Spacing.d256 + Spacing.d4,
      child: SelectTrigger(
        semanticLabel: 'Time zone',
        child: SelectValue(placeholder: 'Select a time zone'),
      ),
    ),
  );
}
