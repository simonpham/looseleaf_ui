import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/alert/alert_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An alert's body in muted ink (red in a destructive alert, soft ink on a
/// note); [AlertDescription.children] stacks paragraphs and actions 4 px
/// apart.
///
/// Mirrors `AlertDescription` in upstream `src/components/ui/alert.tsx`
/// (`grid justify-items-start gap-1 text-sm text-muted-foreground`).
class AlertDescription extends StatelessWidget {
  /// A description holding one [child], usually a [Text].
  const AlertDescription(Widget this.child, {super.key}) : children = const [];

  /// A description stacking [children], like a paragraph and a button.
  const AlertDescription.children(this.children, {super.key}) : child = null;

  /// The single child.
  final Widget? child;

  /// The stacked children.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final color = switch (AlertScope.toneOf(context)) {
      AlertTone.destructive => colors.red,
      AlertTone.note => colors.inkSoft,
      _ => colors.inkMuted,
    };
    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child:
          child ??
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d4,
            children: children,
          ),
    );
  }
}
