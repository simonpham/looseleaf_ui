import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-xs`.
const _maxWidth = 320.0;

/// `text-[1.1rem]`.
const _addressSize = 17.6;

const _mail = [
  (
    id: 'ada',
    from: 'Ada',
    to: 'You',
    line: 'The flap is up, and the letter comes out.',
    stamp: Accent.tomato,
  ),
  (
    id: 'lin',
    from: 'Lin',
    to: 'You',
    line: 'The install page is written. Please read it.',
    stamp: Accent.sky,
  ),
];

class EnvelopeInboxExample extends StatefulWidget {
  const EnvelopeInboxExample({super.key});

  @override
  State<EnvelopeInboxExample> createState() => _EnvelopeInboxExampleState();
}

class _EnvelopeInboxExampleState extends State<EnvelopeInboxExample> {
  String? _open;
  final Set<String> _read = {};

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: const EdgeInsets.only(top: Spacing.d8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d40,
            children: [
              for (final mail in _mail)
                Envelope(
                  seed: mail.id,
                  stamp: mail.stamp,
                  open: _open == mail.id,
                  onOpenChange: (open) => setState(() {
                    _open = switch (open) {
                      true => mail.id,
                      false => null,
                    };
                    if (open) _read.add(mail.id);
                  }),
                  children: [
                    EnvelopeFront(
                      children: [
                        EnvelopeSender(child: Text(mail.from)),
                        EnvelopeAddress(
                          cssFontSize: _addressSize,
                          children: [
                            Text(mail.to),
                            Text(switch (_read.contains(mail.id)) {
                              true => 'read',
                              false => 'unread',
                            }),
                          ],
                        ),
                        EnvelopeTrigger(
                          label:
                              '${switch (_read.contains(mail.id)) {
                                true => 'Reopen',
                                false => 'Open',
                              }} the letter from ${mail.from}',
                        ),
                      ],
                    ),
                    EnvelopeLetter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d4,
                        children: [
                          Text(
                            'Dear you,',
                            style: theme.typography
                                .title(cssSize: 24)
                                .copyWith(height: 1),
                          ),
                          Text(mail.line),
                        ],
                      ),
                    ),
                  ],
                ),
              Button(
                variant: ButtonVariant.secondary,
                disabled: _open == null,
                onPressed: () => setState(() => _open = null),
                child: const Text('Close them all'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
