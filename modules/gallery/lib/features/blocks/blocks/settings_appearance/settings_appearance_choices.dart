import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_appearance/settings_appearance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A legend over choice cards, one radio each, laid out [columns] across
/// once the list is at least [columnsFrom] wide.
class SettingsAppearanceChoices<T> extends StatelessWidget {
  const SettingsAppearanceChoices({
    super.key,
    required this.legend,
    required this.choices,
    required this.value,
    required this.onChanged,
    this.columns = 1,
    this.columnsFrom = 0,
  });

  final String legend;
  final List<AppearanceChoice<T>> choices;
  final T value;
  final ValueChanged<T> onChanged;
  final int columns;
  final double columnsFrom;

  Widget _card(AppearanceChoice<T> choice) => FieldLabel(
    checked: choice.value == value,
    onPressed: switch (choice.ready) {
      true => () => onChanged(choice.value),
      false => null,
    },
    child: Field(
      orientation: FieldOrientation.horizontal,
      disabled: !choice.ready,
      children: [
        FieldContent(
          children: [
            FieldTitle(
              Wrap(
                spacing: Spacing.d8,
                runSpacing: Spacing.d4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(choice.name),
                  if (!choice.ready)
                    const Badge(
                      size: BadgeSize.sm,
                      variant: BadgeVariant.outline,
                      child: Text('soon'),
                    ),
                ],
              ),
            ),
            FieldDescription(Text(choice.help)),
          ],
        ),
        InkRadioGroupItem(value: choice.value, disabled: !choice.ready),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => FieldSet(
    children: [
      FieldLegend(Text(legend)),
      LayoutBuilder(
        builder: (context, constraints) {
          final across = constraints.maxWidth >= columnsFrom && columns > 1;
          return InkRadioGroup<T>(
            value: value,
            onChanged: onChanged,
            semanticLabel: legend,
            children: switch (across) {
              true => [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d12,
                    children: [
                      for (final choice in choices)
                        Expanded(child: _card(choice)),
                    ],
                  ),
                ),
              ],
              false => [
                for (final choice in choices)
                  SizedBox(width: double.infinity, child: _card(choice)),
              ],
            },
          );
        },
      ),
    ],
  );
}
