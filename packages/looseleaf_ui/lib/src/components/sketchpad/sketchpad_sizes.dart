import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';

/// The width picker: fine, medium and bold [SketchpadSize]s, a radio group
/// you move through with the arrow keys.
///
/// Mirrors `SketchpadSizes` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadSizes extends StatelessWidget {
  const SketchpadSizes({super.key, this.children});

  final List<Widget>? children;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: 'Width',
    child: InkRovingFocus(
      axis: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            children ??
            [
              for (final size in SketchSizeName.values)
                SketchpadSize(value: size),
            ],
      ),
    ),
  );
}
