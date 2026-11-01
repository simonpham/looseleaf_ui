import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The pen picker: one [SketchpadTool] per tool, a radio group you move
/// through with the arrow keys.
///
/// [tools] overrides the pad's; [children] replaces the buttons.
///
/// Mirrors `SketchpadTools` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadTools extends StatelessWidget {
  const SketchpadTools({super.key, this.tools, this.children});

  final List<SketchTool>? tools;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    final scope = SketchpadScope.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Tool',
      child: InkRovingFocus(
        axis: Axis.horizontal,
        child: Wrap(
          spacing: Spacing.d2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children:
              children ??
              [
                for (final tool in tools ?? scope.tools)
                  SketchpadTool(value: tool),
              ],
        ),
      ),
    );
  }
}
