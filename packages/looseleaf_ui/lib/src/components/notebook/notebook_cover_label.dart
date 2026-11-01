import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The label on a notebook cover: a slip of index card, turned a little,
/// holding the notebook's name centred in the script face, 20 px bold.
///
/// Mirrors `NotebookCoverLabel` in upstream
/// `src/components/ui/notebook.tsx`.
class NotebookCoverLabel extends StatelessWidget {
  const NotebookCoverLabel(
    this.child, {
    super.key,
    this.tilt = true,
    this.tiltDegrees,
    this.seed,
  });

  /// The name, usually a [Text].
  final Widget child;

  /// False lays the label flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// Pins the card and its tilt.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Paper(
        stock: StockName.indexCard,
        rules: RuleName.none,
        tilt: tilt,
        tiltDegrees: tiltDegrees,
        seed: seed,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d12,
          vertical: Spacing.d8,
        ),
        child: DefaultTextStyle.merge(
          textAlign: TextAlign.center,
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: 20,
            cssLineHeight: 1.25,
            fontWeight: FontWeight.w700,
            color: theme.colors.ink,
          ),
          child: Center(heightFactor: 1, child: child),
        ),
      ),
    );
  }
}
