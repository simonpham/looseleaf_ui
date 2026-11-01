import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/controls/fields/field_frame_ink.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Input recipe params.
///
/// Mirrors `InputParams` in `src/lib/ink/recipes/input-ink.ts`.
final class InputParams {
  /// Params.
  const InputParams({
    this.disabled = false,
    this.invalid = false,
    this.readOnly = false,
  });

  final bool disabled;
  final bool invalid;
  final bool readOnly;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
    if (readOnly) 'readOnly': true,
  };
}

/// The single-line text input: a [drawFieldFrame].
///
/// Mirrors `inputRecipe` in `src/lib/ink/recipes/input-ink.ts`.
final Recipe<InputParams> inputRecipe = defineRecipe<InputParams>(
  id: 'input',
  kind: 'field',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.focus,
    LayerName.invalid,
    LayerName.disabled,
  ],
  lazy: const [LayerName.focus, LayerName.hover],
  pad: 12,
  draw: (ink, size, params, ctx) => drawFieldFrame(
    ink,
    size,
    FieldFrameParams(
      disabled: params.disabled,
      invalid: params.invalid,
      readOnly: params.readOnly,
    ),
    ctx,
  ),
);
