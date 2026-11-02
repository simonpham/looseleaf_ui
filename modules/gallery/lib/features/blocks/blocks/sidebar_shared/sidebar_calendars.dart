import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Folds of calendars, each with a box to tick to show it. The first fold
/// starts open; [value] holds the names ticked.
///
/// Mirrors `Calendars` in upstream
/// `src/blocks/sidebar-shared/sidebar-calendar.tsx`.
class SidebarCalendars extends StatelessWidget {
  const SidebarCalendars({
    super.key,
    required this.groups,
    required this.value,
    required this.onValueChange,
  });

  final List<CalendarGroup> groups;
  final List<String> value;
  final ValueChanged<List<String>> onValueChange;

  void _toggle(String name) => onValueChange(switch (value.contains(name)) {
    true => [
      for (final other in value)
        if (other != name) other,
    ],
    false => [...value, name],
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        for (final (index, group) in groups.indexed) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
            child: Collapsible(
              defaultOpen: index == 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GroupFoldLabel(title: group.name),
                  CollapsibleContent(
                    child: SidebarGroupContent(
                      child: SidebarMenu(
                        children: [
                          for (final item in group.items)
                            SidebarMenuItem(
                              child: Semantics(
                                checked: value.contains(item.name),
                                child: SidebarMenuButton(
                                  onPressed: () => _toggle(item.name),
                                  leading: Opacity(
                                    opacity: switch (value.contains(
                                      item.name,
                                    )) {
                                      true => 1,
                                      false => 0.7,
                                    },
                                    child: InkIcon(
                                      switch (value.contains(item.name)) {
                                        true => 'square-check',
                                        false => 'square',
                                      },
                                      color: item.tone.of(theme.colors),
                                    ),
                                  ),
                                  child: Text(item.name),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Separator(),
        ],
      ],
    );
  }
}
