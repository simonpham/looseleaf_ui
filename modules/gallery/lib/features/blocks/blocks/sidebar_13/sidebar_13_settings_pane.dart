import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One page of settings: a trail, a section picker on phones, the
/// section's name and intro, and its switches.
class Sidebar13SettingsPane extends StatelessWidget {
  const Sidebar13SettingsPane({
    super.key,
    required this.section,
    required this.onSectionChange,
    required this.values,
    required this.onValueChange,
  });

  final SettingsSection section;
  final ValueChanged<String> onSectionChange;

  /// Each switch's value by id.
  final Map<String, bool> values;
  final void Function(String id, bool value) onValueChange;

  static const double _mediumWidth = 768;
  static const double _maxListWidth = 576;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= _mediumWidth;
    final muted = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: Spacing.d64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Breadcrumb(
                child: BreadcrumbList(
                  children: [
                    if (wide) ...[
                      BreadcrumbItem(
                        children: [
                          BreadcrumbLink(
                            onPressed: () {},
                            child: const Text('Settings'),
                          ),
                        ],
                      ),
                      const BreadcrumbSeparator(),
                    ],
                    BreadcrumbItem(
                      children: [BreadcrumbPage(child: Text(section.name))],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.d16,
              0,
              Spacing.d16,
              Spacing.d16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!wide)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.d16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d6,
                      children: [
                        const Label(child: Text('Section')),
                        NativeSelect<String>(
                          value: section.name,
                          semanticLabel: 'Section',
                          onChanged: onSectionChange,
                          options: [
                            for (final item in settingsSections)
                              NativeSelectOption(
                                value: item.name,
                                label: item.name,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Semantics(
                  header: true,
                  child: Text(
                    section.name,
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 24,
                      cssLineHeight: 1.25,
                      fontWeight: FontWeight.w600,
                      color: theme.colors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.d8),
                Text(section.intro, style: muted),
                const SizedBox(height: Spacing.d16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxListWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (index, toggle)
                          in section.toggles.indexed) ...[
                        if (index > 0) const Separator(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.d12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Spacing.d16,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Spacing.d4,
                                  children: [
                                    Label(child: Text(toggle.label)),
                                    Text(toggle.hint, style: muted),
                                  ],
                                ),
                              ),
                              Switch(
                                semanticLabel: toggle.label,
                                value: values[toggle.id] ?? false,
                                onChanged: (value) =>
                                    onValueChange(toggle.id, value),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
