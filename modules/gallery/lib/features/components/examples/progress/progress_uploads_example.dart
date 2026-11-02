import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

typedef _Upload = ({String name, String size, int? percent});

class ProgressUploadsExample extends StatefulWidget {
  const ProgressUploadsExample({super.key});

  @override
  State<ProgressUploadsExample> createState() => _ProgressUploadsExampleState();
}

class _ProgressUploadsExampleState extends State<ProgressUploadsExample> {
  static const List<_Upload> _start = [
    (name: 'field-notes.pdf', size: '2.4 MB', percent: 8),
    (name: 'garden-plan.png', size: '860 KB', percent: 52),
    (name: 'receipts.zip', size: '14 MB', percent: null),
  ];

  List<_Upload> _files = _start;
  Timer? _timer;

  bool get _done => _files.every((file) => file.percent == 100);

  void _tick(Timer _) => setState(() {
    _files = [
      for (final (index, file) in _files.indexed)
        (
          name: file.name,
          size: file.size,
          percent: switch (file.percent) {
            null => 0,
            final percent => math.min(100, percent + 9 + index * 5),
          },
        ),
    ];
  });

  void _toggle() => setState(() {
    if (_timer case final timer?) {
      timer.cancel();
      _timer = null;
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 500), _tick);
  });

  void _reset() => setState(() {
    _timer?.cancel();
    _timer = null;
    _files = _start;
  });

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d20,
        children: [
          for (final file in _files)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d6,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: Spacing.d12,
                  children: [
                    Expanded(
                      child: Row(
                        spacing: Spacing.d6,
                        children: [
                          if (file.percent == 100)
                            InkIcon(
                              'check',
                              size: Spacing.d16,
                              color: theme.colors.green,
                            ),
                          Flexible(
                            child: Text(
                              file.name,
                              style: theme.typography.label(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      switch (file.percent) {
                        null => 'checking',
                        100 => file.size,
                        final percent => '$percent% of ${file.size}',
                      },
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
                  ],
                ),
                Progress(
                  value: file.percent?.toDouble(),
                  tone: switch (file.percent) {
                    100 => ProgressTone.green,
                    _ => ProgressTone.marker,
                  },
                  size: ProgressSize.sm,
                  semanticLabel: file.name,
                ),
              ],
            ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(
                size: ButtonSize.sm,
                onPressed: _toggle,
                child: Text(switch ((_done, _timer != null)) {
                  (true, _) => 'All done',
                  (false, true) => 'Pause',
                  (false, false) => 'Start',
                }),
              ),
              Button(
                size: ButtonSize.sm,
                variant: ButtonVariant.outline,
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
