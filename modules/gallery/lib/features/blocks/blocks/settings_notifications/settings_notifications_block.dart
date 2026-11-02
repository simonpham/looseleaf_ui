import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_notifications/settings_notifications.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Notification settings on a page torn off a pad: how much to hear, a
/// table of what goes where, quiet hours and the weekly summary, checked
/// before they save.
///
/// Mirrors upstream `src/blocks/settings-notifications/page.tsx`.
class SettingsNotificationsBlock extends StatefulWidget {
  const SettingsNotificationsBlock({
    super.key,
    this.initialValue = const NotifyPrefs(),
    this.onSave,
    this.onTest,
  });

  final NotifyPrefs initialValue;

  /// Saves the choices; a throw shows its message in an alert.
  final FutureOr<void> Function(NotifyPrefs prefs)? onSave;

  /// Sends a test note; a throw shows its message in an alert.
  final FutureOr<void> Function(NotifyPrefs prefs)? onTest;

  @override
  State<SettingsNotificationsBlock> createState() =>
      _SettingsNotificationsBlockState();
}

enum _Status { idle, saved, tested }

class _SettingsNotificationsBlockState
    extends State<SettingsNotificationsBlock> {
  static const double _summaryWidth = 224;
  static const double _summaryFrom = 424;

  late NotifyPrefs _prefs = widget.initialValue;
  NotifyProblems _problems = (channels: null, quiet: null);
  var _status = _Status.idle;
  var _busy = false;
  var _failure = '';

  void _change(NotifyPrefs next) => setState(() {
    _prefs = next;
    _status = _Status.idle;
    _problems = (channels: null, quiet: null);
    _failure = '';
  });

  Future<void> _save() async {
    final found = validateNotify(_prefs);
    setState(() => _problems = found);
    if (found.channels != null || found.quiet != null) return;
    setState(() {
      _busy = true;
      _failure = '';
    });
    try {
      await widget.onSave?.call(_prefs);
      if (mounted) setState(() => _status = _Status.saved);
    } on Object catch (error) {
      if (mounted) {
        setState(
          () => _failure = _message(
            error,
            'Your choices were not saved. Nothing has changed, so try again in a moment.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _test() async {
    setState(() => _failure = '');
    try {
      await widget.onTest?.call(_prefs);
      if (mounted) setState(() => _status = _Status.tested);
    } on Object catch (error) {
      if (mounted) {
        setState(
          () => _failure = _message(
            error,
            'The test note could not be sent. Try again in a moment.',
          ),
        );
      }
    }
  }

  static String _message(Object error, String fallback) => switch ('$error') {
    '' => fallback,
    final message => message,
  };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final prefs = _prefs;
    final muted = prefs.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d20,
        vertical: Spacing.d40,
      ),
      child: PaperPage(
        width: PageWidth.xl,
        torn: PageTorn.top,
        seed: 'settings-notifications',
        children: [
          const PageHeader(
            children: [
              PageTitle(
                Text('Notifications'),
                underline: TitleMark.wavy,
                seed: 'notify-title',
              ),
              PageDescription(
                Text(
                  'Decide what is worth a tap on the shoulder, and where it arrives. Everything is quiet until you say otherwise.',
                ),
              ),
            ],
          ),
          Semantics(
            container: true,
            label: 'Notification settings',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d32,
              children: [
                SettingsNotificationsSection(
                  title: 'How much',
                  description:
                      'The biggest dial. The boxes below fine-tune it.',
                  children: [
                    InkRadioGroup<NotifyMode>(
                      value: prefs.mode,
                      semanticLabel: 'How much to hear about',
                      onChanged: (mode) => _change(prefs.copyWith(mode: mode)),
                      children: [
                        for (final mode in NotifyMode.values)
                          SizedBox(
                            width: double.infinity,
                            child: FieldLabel(
                              checked: prefs.mode == mode,
                              onPressed: () =>
                                  _change(prefs.copyWith(mode: mode)),
                              child: Field(
                                orientation: FieldOrientation.horizontal,
                                children: [
                                  FieldContent(
                                    children: [
                                      FieldTitle(Text(mode.title)),
                                      FieldDescription(Text(mode.help)),
                                    ],
                                  ),
                                  InkRadioGroupItem(value: mode),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const Separator(variant: SeparatorVariant.dashed),
                SettingsNotificationsSection(
                  title: 'What goes where',
                  description:
                      'Tick a box to send that kind of news by that route.',
                  children: [
                    SettingsNotificationsTable(
                      prefs: prefs,
                      invalid: _problems.channels != null,
                      onChanged: _change,
                    ),
                    if (_problems.channels case final problem?)
                      FieldError(errors: [problem]),
                  ],
                ),
                const Separator(variant: SeparatorVariant.dashed),
                SettingsNotificationsSection(
                  title: 'Quiet hours',
                  description:
                      'Nothing buzzes, nothing pings. It all waits in the app.',
                  children: [
                    SettingsNotificationsQuiet(
                      prefs: prefs,
                      problem: _problems.quiet,
                      onChanged: _change,
                    ),
                  ],
                ),
                const Separator(variant: SeparatorVariant.dashed),
                SettingsNotificationsSection(
                  title: 'Weekly summary',
                  description:
                      'One email that says what you wrote and who read it.',
                  children: [
                    FieldGroup(
                      children: [
                        Field(
                          disabled: muted,
                          children: [
                            const FieldLabel(child: Text('Send it on')),
                            LayoutBuilder(
                              builder: (context, constraints) => Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: SizedBox(
                                  width: switch (constraints.maxWidth <
                                      _summaryFrom) {
                                    true => constraints.maxWidth,
                                    false => _summaryWidth,
                                  },
                                  child: Select(
                                    value: prefs.summaryDay.name,
                                    disabled: muted,
                                    onChanged: (day) => _change(
                                      prefs.copyWith(
                                        summaryDay: NotifyDay.values.byName(
                                          day,
                                        ),
                                      ),
                                    ),
                                    content: SelectContent(
                                      position: SelectPosition.popper,
                                      children: [
                                        for (final day in NotifyDay.values)
                                          SelectItem(
                                            value: day.name,
                                            child: Text(day.label),
                                          ),
                                      ],
                                    ),
                                    child: const SelectTrigger(
                                      semanticLabel: 'Send it on',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Field(
                          orientation: FieldOrientation.horizontal,
                          disabled: muted,
                          children: [
                            Checkbox(
                              value: prefs.tally,
                              disabled: muted,
                              onChanged: (tally) =>
                                  _change(prefs.copyWith(tally: tally)),
                            ),
                            FieldContent(
                              children: [
                                FieldLabel(
                                  onPressed: switch (muted) {
                                    true => null,
                                    false => () => _change(
                                      prefs.copyWith(tally: !prefs.tally),
                                    ),
                                  },
                                  child: const Text(
                                    'Count my pages in tally marks',
                                  ),
                                ),
                                const FieldDescription(
                                  Text(
                                    'Four strokes and a slash, the way you keep score.',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (_failure.isNotEmpty)
                  Alert(
                    variant: AlertTone.destructive,
                    icon: const InkIcon('circle-alert'),
                    children: [
                      const AlertTitle(Text('That did not go through')),
                      AlertDescription(Text(_failure)),
                    ],
                  ),
                if (_status == _Status.tested)
                  const Alert(
                    variant: AlertTone.success,
                    icon: InkIcon('circle-check'),
                    children: [
                      AlertTitle(Text('A test note is on its way')),
                      AlertDescription(
                        Text(
                          'It follows the choices above, so if it does not arrive, look at what is ticked.',
                        ),
                      ),
                    ],
                  ),
                Wrap(
                  spacing: Spacing.d12,
                  runSpacing: Spacing.d12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Button(
                      onPressed: () => unawaited(_save()),
                      child: Text(switch (_busy) {
                        true => 'Saving…',
                        false => 'Save preferences',
                      }),
                    ),
                    Button(
                      variant: ButtonVariant.outline,
                      onPressed: () => unawaited(_test()),
                      child: const Text('Send a test'),
                    ),
                    if (_status == _Status.saved)
                      Semantics(
                        liveRegion: true,
                        child: IconTheme(
                          data: IconThemeData(color: theme.colors.green),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: Spacing.d8,
                            children: [
                              const InkIcon('circle-check'),
                              Flexible(
                                child: Text(
                                  'Saved. We will follow these from now on.',
                                  style: theme.typography
                                      .interface(
                                        cssSize: 14,
                                        color: theme.colors.green,
                                      )
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
