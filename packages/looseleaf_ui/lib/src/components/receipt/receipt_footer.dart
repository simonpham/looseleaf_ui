import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The thank-you line at the foot of a receipt: centred, muted, 12 px.
///
/// Mirrors `ReceiptFooter` in upstream `src/components/ui/receipt.tsx`.
class ReceiptFooter extends StatelessWidget {
  const ReceiptFooter(this.child, {super.key});

  /// The line, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      textAlign: TextAlign.center,
      style: theme.typography.face(
        KevinSansFace.type,
        cssSize: 12,
        cssLineHeight: 16 / 12,
        color: theme.colors.inkMuted,
      ),
      child: child,
    );
  }
}
