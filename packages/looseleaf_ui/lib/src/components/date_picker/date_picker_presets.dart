import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_preset.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The shortcuts beside the calendar: small ghost buttons in a labelled
/// group, wrapping above the calendar on narrow screens and stacked in a
/// 144 px column beside it from 640 px up.
///
/// Mirrors `DatePickerPresets` in upstream
/// `src/components/ui/date-picker.tsx`.
class DatePickerPresets<T> extends StatelessWidget {
  const DatePickerPresets({
    super.key,
    required this.presets,
    required this.onPick,
    this.label = 'Presets',
  });

  final List<DatePreset<T>> presets;

  /// Called with the chosen preset.
  final ValueChanged<DatePreset<T>> onPick;

  /// The group's accessible name.
  final String label;

  /// The width from which the presets stand in a column (`sm:`).
  static const double wideFrom = 640;

  /// The column's inner width: `sm:w-36` less its `p-3`.
  static const double columnWidth = 120;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= wideFrom;
    final rule = LooseleafTheme.of(context).colors.pencilMark;
    final buttons = [
      for (final preset in presets)
        Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.sm,
          onPressed: () => onPick(preset),
          child: Text(preset.label),
        ),
    ];
    final side = BorderSide(color: rule.withValues(alpha: rule.a * 0.4));
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: switch (wide) {
            true => BorderDirectional(end: side),
            false => Border(bottom: side),
          },
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.d12,
            Spacing.d12,
            Spacing.d12,
            switch (wide) {
              true => Spacing.d12,
              false => Spacing.d8,
            },
          ),
          child: switch (wide) {
            true => SizedBox(
              width: columnWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d4,
                children: [
                  for (final button in buttons)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: button,
                    ),
                ],
              ),
            ),
            false => Wrap(
              spacing: Spacing.d4,
              runSpacing: Spacing.d4,
              children: buttons,
            ),
          },
        ),
      ),
    );
  }
}
