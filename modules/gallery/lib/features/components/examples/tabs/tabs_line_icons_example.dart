import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TabsLineIconsExample extends StatelessWidget {
  const TabsLineIconsExample({super.key});

  static const _maxWidth = Spacing.d448;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Tabs(
        defaultValue: 'profile',
        children: [
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TabsList(
              variant: TabsVariant.line,
              children: [
                TabsTrigger(
                  value: 'profile',
                  child: _IconLabel(icon: 'user', label: 'Profile'),
                ),
                TabsTrigger(
                  value: 'settings',
                  child: _IconLabel(icon: 'settings', label: 'Settings'),
                ),
                TabsTrigger(
                  value: 'alerts',
                  disabled: true,
                  child: _IconLabel(icon: 'bell', label: 'Alerts'),
                ),
                TabsTrigger(
                  value: 'search',
                  child: _IconLabel(icon: 'search', label: 'Search'),
                ),
              ],
            ),
          ),
          TabsContent(
            value: 'profile',
            child: Text(
              'Your name, your photo and the sentence people see first.',
              style: muted,
            ),
          ),
          TabsContent(
            value: 'settings',
            child: Text(
              'Language, density and how much the ink moves.',
              style: muted,
            ),
          ),
          TabsContent(
            value: 'search',
            child: Text('Find a page, a note or a person.', style: muted),
          ),
        ],
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d6,
    children: [InkIcon(icon), Text(label)],
  );
}
