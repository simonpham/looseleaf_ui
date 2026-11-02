import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ResizableMailExample extends StatefulWidget {
  const ResizableMailExample({super.key});

  @override
  State<ResizableMailExample> createState() => _ResizableMailExampleState();
}

class _ResizableMailExampleState extends State<ResizableMailExample> {
  static const _maxWidth = 768.0;
  static const _height = 320.0;
  static const _mails = [
    (from: 'Ada', subject: 'Tabs landed'),
    (from: 'Jo', subject: 'Table rules, by hand'),
    (from: 'Mika', subject: 'Redrew the ticks'),
    (from: 'Sam', subject: 'September invoice'),
  ];

  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.interface(cssSize: 14);
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    final mail = _mails[_open];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        seed: 'mail',
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: _height,
            child: ResizablePanelGroup(
              children: [
                ResizablePanel(
                  defaultSize: 30,
                  minSize: 20,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Spacing.d12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d4,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.d4),
                          child: Text(
                            'Inbox',
                            style: theme.typography.face(
                              KevinSansFace.script,
                              cssSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        for (final (index, item) in _mails.indexed)
                          InkItem(
                            size: ItemSize.sm,
                            onPressed: () => setState(() => _open = index),
                            forcedStates: {
                              if (index == _open) InkState.hovered,
                            },
                            children: [
                              ItemContent(
                                children: [
                                  Text(
                                    item.from,
                                    style: small.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(item.subject, style: muted),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const ResizableHandle(
                  withHandle: true,
                  semanticLabel: 'Resize the inbox',
                ),
                ResizablePanel(
                  defaultSize: 45,
                  minSize: 30,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Spacing.d16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d8,
                      children: [
                        Text(
                          mail.subject,
                          style: theme.typography.face(
                            KevinSansFace.script,
                            cssSize: 24,
                            cssLineHeight: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'From ${mail.from}. The rules are pulled once and printed by CSS, so a hundred rows cost no drawings.',
                          style: muted,
                        ),
                        Text(
                          'Drag the seams, or focus one and press the arrow keys.',
                          style: muted,
                        ),
                      ],
                    ),
                  ),
                ),
                const ResizableHandle(semanticLabel: 'Resize the details'),
                ResizablePanel(
                  defaultSize: 25,
                  minSize: 15,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Spacing.d16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d4,
                      children: [
                        Text(
                          'Details',
                          style: small.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text('From ${mail.from}', style: muted),
                        Text('Received 09:41', style: muted),
                        Text('Pencil, 1 page', style: muted),
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
