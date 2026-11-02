import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TabsVerticalExample extends StatelessWidget {
  const TabsVerticalExample({super.key});

  static const _maxWidth = 512.0;
  static const _sections = [
    (
      value: 'general',
      title: 'General',
      text: 'Name the notebook and choose who can see it.',
    ),
    (
      value: 'notifications',
      title: 'Notifications',
      text: 'Choose what lands in your inbox, and when.',
    ),
    (
      value: 'billing',
      title: 'Billing',
      text: 'Your plan, your invoices and the card on file.',
    ),
    (
      value: 'danger',
      title: 'Danger zone',
      text: 'Archive or delete the notebook. There is no undo.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Tabs(
        defaultValue: 'notifications',
        orientation: TabsOrientation.vertical,
        children: [
          SizedBox(
            width: Spacing.d160,
            child: TabsList(
              children: [
                for (final section in _sections)
                  TabsTrigger(value: section.value, child: Text(section.title)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final section in _sections)
                  TabsContent(
                    value: section.value,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: Spacing.d12,
                        top: Spacing.d4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d8,
                        children: [
                          Text(
                            section.title,
                            style: theme.typography.face(
                              KevinSansFace.script,
                              cssSize: 24,
                              cssLineHeight: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            section.text,
                            style: theme.typography.interface(
                              cssSize: 14,
                              color: theme.colors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
