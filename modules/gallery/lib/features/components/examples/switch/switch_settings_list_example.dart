import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SwitchSettingsListExample extends StatefulWidget {
  const SwitchSettingsListExample({super.key});

  @override
  State<SwitchSettingsListExample> createState() =>
      _SwitchSettingsListExampleState();
}

class _SwitchSettingsListExampleState extends State<SwitchSettingsListExample> {
  static const _maxWidth = Spacing.d448;

  static const _settings = [
    (
      id: 'ruled',
      title: 'Show ruled lines',
      help: 'Blue pencil rules behind everything you write.',
      locked: false,
    ),
    (
      id: 'hints',
      title: 'Highlighter hints',
      help: 'Underline what changed since you last looked.',
      locked: false,
    ),
    (
      id: 'sound',
      title: 'Pencil scratch sound',
      help: 'A soft scratch while you type. Off is quieter.',
      locked: false,
    ),
    (
      id: 'sync',
      title: 'Sync to the cloud',
      help: 'Locked by your administrator.',
      locked: true,
    ),
  ];

  String? _hovered;

  final _on = {'ruled': true, 'hints': true, 'sound': false, 'sync': true};

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        children: [
          for (final (index, setting) in _settings.indexed)
            MouseRegion(
              onEnter: (_) => setState(() => _hovered = setting.id),
              onExit: (_) => setState(() => _hovered = null),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: switch (index) {
                      0 => BorderSide.none,
                      _ => BorderSide(
                        color: theme.colors.ruleBlue.withValues(alpha: 0.6),
                      ),
                    },
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: switch (index) {
                      0 => 0,
                      _ => Spacing.d14,
                    },
                    bottom: Spacing.d14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d24,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Spacing.d4,
                          children: [
                            Label(
                              disabled: setting.locked,
                              onPressed: () => _toggle(setting.id),
                              child: Text(setting.title),
                            ),
                            Text(
                              setting.help,
                              style: theme.typography.interface(
                                cssSize: 14,
                                color: theme.colors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.d2),
                        child: Switch(
                          value: _on[setting.id] ?? false,
                          onChanged: (_) => _toggle(setting.id),
                          disabled: setting.locked,
                          semanticLabel: setting.title,
                          forcedStates: {
                            if (_hovered == setting.id) InkState.hovered,
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggle(String id) {
    if (_settings.any((setting) => setting.id == id && setting.locked)) return;
    setState(() => _on[id] = !(_on[id] ?? false));
  }
}
