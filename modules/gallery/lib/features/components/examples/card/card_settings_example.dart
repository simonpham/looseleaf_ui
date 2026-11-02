import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = 384.0;

const _rows = [
  (id: 'comments', label: 'Comments on your notes', on: true),
  (id: 'replies', label: 'Replies to your questions', on: true),
  (id: 'weekly', label: 'The weekly summary, Fridays', on: false),
];

class CardSettingsExample extends StatefulWidget {
  const CardSettingsExample({super.key});

  @override
  State<CardSettingsExample> createState() => _CardSettingsExampleState();
}

class _CardSettingsExampleState extends State<CardSettingsExample> {
  late final Map<String, bool> _on = {for (final row in _rows) row.id: row.on};

  void _toggle(String id) => setState(() => _on[id] = !(_on[id] ?? false));

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          seed: 'settings',
          children: [
            CardHeader(
              children: [
                const CardTitle(Text('Notifications')),
                const CardDescription(Text('Choose what lands in your inbox.')),
                CardAction(
                  child: Button(
                    variant: ButtonVariant.link,
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
            CardContent(
              child: Column(
                spacing: Spacing.d12,
                children: [
                  for (final row in _rows)
                    Row(
                      spacing: Spacing.d16,
                      children: [
                        Expanded(
                          child: Label(
                            onPressed: () => _toggle(row.id),
                            child: Text(row.label),
                          ),
                        ),
                        Switch(
                          value: _on[row.id] ?? false,
                          onChanged: (value) =>
                              setState(() => _on[row.id] = value),
                          semanticLabel: row.label,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            CardFooter(
              divider: true,
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: Spacing.d8,
              children: [
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                Button(
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
