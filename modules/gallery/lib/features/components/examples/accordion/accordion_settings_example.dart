import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AccordionSettingsExample extends StatefulWidget {
  const AccordionSettingsExample({super.key});

  @override
  State<AccordionSettingsExample> createState() =>
      _AccordionSettingsExampleState();
}

class _AccordionSettingsExampleState extends State<AccordionSettingsExample> {
  static const _maxWidth = 448.0;
  static const _steps = ['profile', 'notifications', 'security'];

  final _name = TextEditingController(text: 'Ada Lovelace');
  final _nameFocus = FocusNode();
  final _bioFocus = FocusNode();
  String _open = 'profile';

  String get _next =>
      _steps[math.min(_steps.indexOf(_open) + 1, _steps.length - 1)];

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    _bioFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        seed: 'acc-settings',
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Settings')),
              CardDescription(
                Text('Three short pages. Open them in any order.'),
              ),
            ],
          ),
          CardContent(
            child: Accordion(
              collapsible: true,
              value: {if (_open.isNotEmpty) _open},
              onValueChange: (open) =>
                  setState(() => _open = open.firstOrNull ?? ''),
              children: [
                AccordionItem(
                  value: 'profile',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AccordionTrigger(child: Text('Profile')),
                      AccordionContent(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.d12,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: Spacing.d8,
                              children: [
                                Label(
                                  focusNode: _nameFocus,
                                  child: const Text('Name'),
                                ),
                                Input(controller: _name, focusNode: _nameFocus),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: Spacing.d8,
                              children: [
                                Label(
                                  focusNode: _bioFocus,
                                  child: const Text('One line about you'),
                                ),
                                Input(
                                  focusNode: _bioFocus,
                                  placeholder: 'Mathematician, mostly',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const AccordionItem(
                  value: 'notifications',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccordionTrigger(child: Text('Notifications')),
                      AccordionContent(
                        child: Text(
                          'We send a summary on Fridays and nothing else. Change that here whenever you like.',
                        ),
                      ),
                    ],
                  ),
                ),
                const AccordionItem(
                  value: 'security',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccordionTrigger(child: Text('Security')),
                      AccordionContent(
                        child: Text(
                          'Passkeys are on. Two devices are signed in.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CardFooter(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Open: ${switch (_open) {
                  '' => 'none',
                  _ => _open,
                }}',
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
              Button(
                size: ButtonSize.sm,
                onPressed: () => setState(() => _open = _next),
                child: const Text('Next page'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
