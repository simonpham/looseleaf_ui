import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A label tag's price in the type face, 20 px with tabular figures, in a
/// red darkened with ink, pushed to the foot of the tag. Use it as a direct
/// child of a `LabelTag`.
///
/// Mirrors `LabelTagPrice` in upstream `src/components/ui/label-tag.tsx`.
class LabelTagPrice extends StatelessWidget {
  const LabelTagPrice(this.child, {super.key});

  /// The price, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    return Expanded(
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: DefaultTextStyle.merge(
          style: theme.typography
              .face(
                KevinSansFace.type,
                cssSize: 20,
                cssLineHeight: 1,
                color: Color.lerp(colors.ink, colors.red, 0.6),
              )
              .copyWith(
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                  FontFeature.liningFigures(),
                ],
              ),
          child: child,
        ),
      ),
    );
  }
}
