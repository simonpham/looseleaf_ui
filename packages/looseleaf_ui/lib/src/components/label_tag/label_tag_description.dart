import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Small soft-ink text under a label tag's title.
///
/// Mirrors `LabelTagDescription` in upstream
/// `src/components/ui/label-tag.tsx`.
class LabelTagDescription extends StatelessWidget {
  const LabelTagDescription(this.child, {super.key});

  /// The description, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 1.25,
        color: theme.colors.inkSoft,
      ),
      child: child,
    );
  }
}
