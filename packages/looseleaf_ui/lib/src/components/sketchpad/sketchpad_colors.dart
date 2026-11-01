import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';

/// The color picker: one [SketchpadColor] per ink of [colors], a radio
/// group you move through with the arrow keys.
///
/// Mirrors `SketchpadColors` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadColors extends StatelessWidget {
  const SketchpadColors({
    super.key,
    this.colors = SketchColor.values,
    this.children,
  });

  final List<SketchColor> colors;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: 'Color',
    child: InkRovingFocus(
      axis: Axis.horizontal,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children:
            children ??
            [for (final color in colors) SketchpadColor(value: color)],
      ),
    ),
  );
}
