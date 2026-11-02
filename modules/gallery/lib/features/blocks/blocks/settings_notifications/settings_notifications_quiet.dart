import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_notifications/settings_notifications.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Quiet hours: the switch, then from, until and the days it applies to.
class SettingsNotificationsQuiet extends StatelessWidget {
  const SettingsNotificationsQuiet({
    super.key,
    required this.prefs,
    required this.onChanged,
    this.problem,
  });

  static const double _pairFrom = 424;

  final NotifyPrefs prefs;
  final ValueChanged<NotifyPrefs> onChanged;
  final String? problem;

  Widget _time(String label, String value, ValueChanged<String> onPicked) =>
      Field(
        invalid: problem != null,
        children: [
          FieldLabel(child: Text(label)),
          NativeSelect<String>(
            value: value,
            invalid: problem != null,
            semanticLabel: label,
            options: [
              for (final time in notifyTimes)
                NativeSelectOption(value: time.value, label: time.label),
            ],
            onChanged: onPicked,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final muted = prefs.muted;
    final on = prefs.quiet && !muted;
    final from = _time(
      'From',
      prefs.quietFrom,
      (time) => onChanged(prefs.copyWith(quietFrom: time)),
    );
    final until = _time(
      'Until',
      prefs.quietTo,
      (time) => onChanged(prefs.copyWith(quietTo: time)),
    );
    return FieldGroup(
      children: [
        Field(
          orientation: FieldOrientation.horizontal,
          disabled: muted,
          children: [
            FieldContent(
              children: [
                FieldLabel(
                  onPressed: switch (muted) {
                    true => null,
                    false => () => onChanged(prefs.copyWith(quiet: !on)),
                  },
                  child: const Text('Hush the desk at night'),
                ),
                const FieldDescription(
                  Text(
                    'Push and email are held back; the in-app list keeps filling.',
                  ),
                ),
              ],
            ),
            Switch(
              value: on,
              disabled: muted,
              semanticLabel: 'Hush the desk at night',
              onChanged: (quiet) => onChanged(prefs.copyWith(quiet: quiet)),
            ),
          ],
        ),
        if (on)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _pairFrom) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: [from, until],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d16,
                children: [
                  Expanded(child: from),
                  Expanded(child: until),
                ],
              );
            },
          ),
        if (on)
          Field(
            invalid: problem != null,
            children: [
              const FieldLabel(child: Text('On these days')),
              ToggleGroup<NotifyDay>(
                type: ToggleGroupType.multiple,
                variant: ToggleVariant.outline,
                value: prefs.quietDays,
                semanticLabel: 'On these days',
                onChanged: (days) => onChanged(prefs.copyWith(quietDays: days)),
                children: [
                  for (final day in NotifyDay.values)
                    ToggleGroupItem(
                      value: day,
                      semanticLabel: day.label,
                      child: Text(day.short),
                    ),
                ],
              ),
              if (problem case final message?) FieldError(errors: [message]),
            ],
          ),
      ],
    );
  }
}
