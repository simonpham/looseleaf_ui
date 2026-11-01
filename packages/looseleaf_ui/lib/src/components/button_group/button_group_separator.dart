import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/separator/separator.dart';

/// A pencil line between two members of a [ButtonGroup], stretched to the
/// group's height (or width in a vertical group). Filled buttons want one,
/// since two markers touching read as one blot.
///
/// Mirrors `ButtonGroupSeparator` in upstream
/// `src/components/ui/button-group.tsx`.
class ButtonGroupSeparator extends StatelessWidget {
  const ButtonGroupSeparator({
    super.key,
    this.orientation = SeparatorOrientation.vertical,
    this.variant = SeparatorVariant.pencil,
    this.seed,
  });

  /// Vertical in a horizontal group; horizontal in a vertical one.
  final SeparatorOrientation orientation;

  /// How the line is drawn.
  final SeparatorVariant variant;

  /// Pins the drawing.
  final String? seed;

  @override
  Widget build(BuildContext context) =>
      Separator(orientation: orientation, variant: variant, seed: seed);
}
