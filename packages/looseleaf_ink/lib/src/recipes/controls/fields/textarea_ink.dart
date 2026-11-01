import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/controls/fields/field_frame_ink.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Textarea recipe params.
///
/// Mirrors `TextareaParams` in `src/lib/ink/recipes/textarea-ink.ts`.
final class TextareaParams {
  /// Params.
  const TextareaParams({
    this.disabled = false,
    this.invalid = false,
    this.readOnly = false,
    this.ruled = false,
    this.lineHeight,
    this.ruleTop,
    this.grip = false,
  });

  final bool disabled;
  final bool invalid;
  final bool readOnly;

  /// Draws notebook rules.
  final bool ruled;

  /// The rule spacing, 28 when null.
  final double? lineHeight;

  /// The top of the first line, 8 when null.
  final double? ruleTop;

  /// Draws a resize grip.
  final bool grip;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
    if (readOnly) 'readOnly': true,
    if (ruled) 'ruled': true,
    'lineHeight': ?lineHeight,
    'ruleTop': ?ruleTop,
    if (grip) 'grip': true,
  };
}

/// The multiline text field: a [drawFieldFrame], optionally ruled.
///
/// Mirrors `textareaRecipe` in `src/lib/ink/recipes/textarea-ink.ts`.
final Recipe<TextareaParams> textareaRecipe = defineRecipe<TextareaParams>(
  id: 'textarea',
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
      multiline: true,
      ruled: params.ruled,
      lineHeight: params.lineHeight,
      ruleTop: params.ruleTop,
      grip: params.grip,
    ),
    ctx,
  ),
);
