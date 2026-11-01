import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The strip of paper the sketchpad's controls sit on: a cut slip with a
/// hairline shadow, its [children] wrapping onto more lines as needed. The
/// first line spreads its items to both ends, the way upstream pushes the
/// undo buttons over with `ms-auto`.
///
/// Mirrors `SketchpadToolbar` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadToolbar extends StatelessWidget {
  const SketchpadToolbar({
    super.key,
    required this.children,
    this.semanticLabel = 'Drawing tools',
  });

  final List<Widget> children;

  /// The group's accessible name.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: semanticLabel,
    child: Paper(
      stock: StockName.slip,
      edge: const EdgeSpec(),
      tilt: false,
      shadow: PaperShadow.hair,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d8,
        vertical: Spacing.d6,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Spacing.d12,
        runSpacing: Spacing.d4,
        children: children,
      ),
    ),
  );
}
