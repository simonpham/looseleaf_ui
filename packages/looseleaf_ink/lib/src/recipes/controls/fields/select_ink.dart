import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/controls/fields/select_frame_ink.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Params of the select-like triggers: select, native select, date picker
/// and combobox trigger. [cell] is the chevron cell width (32 when null).
///
/// Mirrors `SelectParams`, `NativeSelectParams`, `DatePickerParams` and
/// `ComboboxTriggerParams` in `src/lib/ink/recipes/`.
final class SelectParams {
  /// Params.
  const SelectParams({this.disabled = false, this.invalid = false, this.cell});

  final bool disabled;
  final bool invalid;
  final double? cell;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
    'cell': ?cell,
  };
}

const List<LayerName> _openableLayers = [
  LayerName.rest,
  LayerName.hover,
  LayerName.focus,
  LayerName.open,
  LayerName.invalid,
  LayerName.disabled,
];

Recipe<SelectParams> _selectLike(
  String id, {
  required bool openable,
}) => defineRecipe<SelectParams>(
  id: id,
  kind: 'field',
  layers: switch (openable) {
    true => _openableLayers,
    false => const [
      LayerName.rest,
      LayerName.hover,
      LayerName.focus,
      LayerName.invalid,
      LayerName.disabled,
    ],
  },
  lazy: const [LayerName.focus, LayerName.hover],
  pad: 12,
  draw: (ink, size, params, ctx) => drawSelectFrame(
    ink,
    size,
    SelectFrameParams(
      disabled: params.disabled,
      invalid: params.invalid,
      openable: openable,
      cell: params.cell,
    ),
    ctx,
  ),
);

/// The select trigger, with an `open` layer.
///
/// Mirrors `selectRecipe` in `src/lib/ink/recipes/select-ink.ts`.
final Recipe<SelectParams> selectRecipe = _selectLike('select', openable: true);

/// The native select, without an `open` layer.
///
/// Mirrors `nativeSelectRecipe` in `src/lib/ink/recipes/native-select-ink.ts`.
final Recipe<SelectParams> nativeSelectRecipe = _selectLike(
  'native-select',
  openable: false,
);

/// The date picker trigger.
///
/// Mirrors `datePickerRecipe` in `src/lib/ink/recipes/date-picker-ink.ts`.
final Recipe<SelectParams> datePickerRecipe = _selectLike(
  'date-picker',
  openable: true,
);

/// The combobox trigger.
///
/// Mirrors `comboboxTriggerRecipe` in `src/lib/ink/recipes/combobox-ink.ts`.
final Recipe<SelectParams> comboboxTriggerRecipe = _selectLike(
  'combobox-trigger',
  openable: true,
);
