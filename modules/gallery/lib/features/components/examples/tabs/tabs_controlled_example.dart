import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TabsControlledExample extends StatefulWidget {
  const TabsControlledExample({super.key});

  @override
  State<TabsControlledExample> createState() => _TabsControlledExampleState();
}

class _TabsControlledExampleState extends State<TabsControlledExample> {
  static const _maxWidth = 384.0;
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu'];

  String _day = 'Tue';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final at = _days.indexOf(_day);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Tabs(
            value: _day,
            onValueChange: (day) => setState(() => _day = day),
            activationMode: TabsActivationMode.manual,
            children: [
              TabsList(
                children: [
                  for (final day in _days)
                    TabsTrigger(value: day, child: Text(day)),
                ],
              ),
              for (final day in _days)
                TabsContent(
                  value: day,
                  child: Text(
                    'Nothing planned on $day. A good day for a very small plan.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
            ],
          ),
          Row(
            spacing: Spacing.d8,
            children: [
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                disabled: at == 0,
                onPressed: () => setState(() => _day = _days[at - 1]),
                child: const Text('Earlier'),
              ),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                disabled: at == _days.length - 1,
                onPressed: () => setState(() => _day = _days[at + 1]),
                child: const Text('Later'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
