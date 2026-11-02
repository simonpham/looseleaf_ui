import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A taped card of this week in three tabs: a to-do list that counts what
/// is ticked, the sprint's progress and the team.
///
/// Mirrors upstream `src/docs/content/home/tabs-card.tsx`.
class TabsCard extends StatefulWidget {
  const TabsCard({super.key});

  @override
  State<TabsCard> createState() => _TabsCardState();
}

class _TabsCardState extends State<TabsCard> {
  static const List<(String, String)> _tasks = [
    ('ship', 'Ship the sign-in card'),
    ('draw', 'Draw the dashboard'),
    ('focus', 'Fix the focus ring'),
    ('water', 'Water the plant'),
  ];

  static const List<String> _team = [
    'Ada Lovelace',
    'Jo Okafor',
    'Mika Kobayashi',
    'Sam Reyes',
    'Priya Nair',
  ];

  final Set<String> _done = {'ship', 'draw'};

  void _mark(String id, bool done) => setState(() {
    if (done) {
      _done.add(id);
      return;
    }
    _done.remove(id);
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final script = theme.typography.face(
      KevinSansFace.script,
      cssSize: 24,
      cssLineHeight: 1,
      color: theme.colors.ink,
    );
    return Card(
      seed: 'home-tabs',
      tape: PaperTape.top,
      gap: Spacing.d12,
      children: [
        CardHeader(
          children: [
            const CardTitle(Text('This week')),
            CardDescription(
              Text('${_done.length} of ${_tasks.length} done'),
            ),
          ],
        ),
        CardContent(
          child: Tabs(
            defaultValue: 'todo',
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: TabsList(
                  children: [
                    TabsTrigger(value: 'todo', child: Text('To do')),
                    TabsTrigger(value: 'sprint', child: Text('Sprint')),
                    TabsTrigger(value: 'team', child: Text('Team')),
                  ],
                ),
              ),
              TabsContent(
                value: 'todo',
                child: Padding(
                  padding: const EdgeInsets.only(top: Spacing.d12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d8,
                    children: [
                      for (final (id, label) in _tasks)
                        Checkbox(
                          value: _done.contains(id),
                          onChanged: (done) => _mark(id, done),
                          seed: 'home-task-$id',
                          label: Text(
                            label,
                            style: switch (_done.contains(id)) {
                              true =>
                                theme.typography
                                    .interface(
                                      cssSize: 16,
                                      color: theme.colors.inkMuted,
                                    )
                                    .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: theme.colors.red,
                                    ),
                              false => theme.typography.interface(
                                cssSize: 16,
                                color: theme.colors.ink,
                              ),
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              TabsContent(
                value: 'sprint',
                child: Padding(
                  padding: const EdgeInsets.only(top: Spacing.d16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d12,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text('Sprint 7 of 10', style: script),
                          ),
                          Text(
                            '70%',
                            style: script.copyWith(color: theme.colors.red),
                          ),
                        ],
                      ),
                      const Progress(
                        value: 70,
                        seed: 'home-sprint',
                        semanticLabel: 'Sprint progress',
                      ),
                    ],
                  ),
                ),
              ),
              TabsContent(
                value: 'team',
                child: Padding(
                  padding: const EdgeInsets.only(top: Spacing.d16),
                  child: Wrap(
                    spacing: Spacing.d12,
                    runSpacing: Spacing.d12,
                    children: [
                      for (final name in _team)
                        Avatar(
                          size: AvatarSize.lg,
                          children: [AvatarFallback(name: name)],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
