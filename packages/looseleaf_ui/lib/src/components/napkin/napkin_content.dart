import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The note on a napkin, in the script face at 24 px as if in marker. It
/// grows to fill the napkin, so a [NapkinFooter] after it sits at the foot.
/// Use it as a direct child of a `Napkin`.
///
/// Mirrors `NapkinContent` in upstream `src/components/ui/napkin.tsx`.
class NapkinContent extends StatelessWidget {
  const NapkinContent(this.child, {super.key});

  /// The note, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Expanded(
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 24,
          cssLineHeight: 1.15,
          color: theme.colors.ink,
        ),
        child: Align(alignment: AlignmentDirectional.topStart, child: child),
      ),
    );
  }
}
