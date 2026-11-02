import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The note on a napkin, in the script face at 24 px as if in marker. As a
/// direct child of a `Napkin` it grows to fill the napkin, so a
/// [NapkinFooter] after it sits at the foot, and the note sits at
/// [alignment] in that space (`Alignment.center` for upstream's
/// `flex items-center justify-center`).
///
/// Mirrors `NapkinContent` in upstream `src/components/ui/napkin.tsx`.
class NapkinContent extends StatelessWidget {
  const NapkinContent(
    this.child, {
    super.key,
    this.alignment = AlignmentDirectional.topStart,
  });

  /// The note, usually a [Text].
  final Widget child;

  /// Where the note sits in the space the napkin gives it.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.script,
        cssSize: 24,
        cssLineHeight: 1.15,
        color: theme.colors.ink,
      ),
      child: Align(alignment: alignment, child: child),
    );
  }
}
