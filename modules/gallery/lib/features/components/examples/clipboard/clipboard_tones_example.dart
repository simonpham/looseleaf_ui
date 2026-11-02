import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ClipboardTonesExample extends StatelessWidget {
  const ClipboardTonesExample({super.key});

  static const _boards = <(String, Accent?, List<String>)>[
    ('hardboard', null, ['milk', 'eggs', 'tea']),
    ('teal', Accent.teal, ['rent', 'post', 'call']),
    ('tomato', Accent.tomato, ['jam', 'figs', 'rye']),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.d16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: Spacing.d32,
        runSpacing: Spacing.d48,
        children: [
          for (final (index, (name, tone, list)) in _boards.indexed)
            SizedBox(
              width: Spacing.d192,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d12,
                children: [
                  InkClipboard(
                    tone: tone,
                    seed: name,
                    tiltDegrees: switch (index.isOdd) {
                      true => 1,
                      false => -1,
                    },
                    minHeight: Spacing.d288,
                    children: [
                      ClipboardPaper(
                        seed: '$name-p',
                        minHeight: Spacing.d160,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          Spacing.d48,
                          Spacing.d36 * 2,
                          Spacing.d12,
                          Spacing.d20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in list)
                              SizedBox(
                                height: Spacing.d28,
                                child: Text(
                                  item,
                                  style: theme.typography.interface(
                                    cssSize: 17,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.typography.stamp(
                      cssSize: 14,
                      color: theme.colors.ink,
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
