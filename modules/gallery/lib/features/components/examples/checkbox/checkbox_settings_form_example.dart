import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CheckboxSettingsFormExample extends StatefulWidget {
  const CheckboxSettingsFormExample({super.key});

  @override
  State<CheckboxSettingsFormExample> createState() =>
      _CheckboxSettingsFormExampleState();
}

class _CheckboxSettingsFormExampleState
    extends State<CheckboxSettingsFormExample> {
  static const _maxWidth = Spacing.d384;
  static const _topics = [
    ('comments', 'Comments'),
    ('replies', 'Replies'),
    ('mentions', 'Mentions'),
  ];

  final _notify = <String>{'comments', 'replies'};
  bool _agree = false;
  String _sent = '';

  void _save() {
    if (!_agree) return;
    final picked = [
      for (final (topic, _) in _topics)
        if (_notify.contains(topic)) topic,
    ];
    final summary = switch (picked) {
      [] => 'nothing',
      _ => picked.join(', '),
    };
    setState(() => _sent = 'Saved: $summary');
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Semantics(
            container: true,
            label: 'Tell me about',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d12,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: Spacing.d8),
                  child: Text(
                    'Tell me about',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                for (final (topic, label) in _topics)
                  Checkbox(
                    value: _notify.contains(topic),
                    onChanged: (value) => setState(() {
                      if (value) {
                        _notify.add(topic);
                        return;
                      }
                      _notify.remove(topic);
                    }),
                    label: Text(label),
                  ),
              ],
            ),
          ),
          Row(
            spacing: Spacing.d8,
            children: [
              Checkbox(
                value: _agree,
                onChanged: (value) => setState(() => _agree = value),
                semanticLabel: 'I have read the small print',
              ),
              Flexible(
                child: Label(
                  required: true,
                  onPressed: () => setState(() => _agree = !_agree),
                  child: const Text('I have read the small print'),
                ),
              ),
            ],
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(onPressed: _save, child: const Text('Save')),
              Flexible(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _sent,
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
