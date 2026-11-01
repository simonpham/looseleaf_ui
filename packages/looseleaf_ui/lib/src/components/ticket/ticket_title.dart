import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A ticket's big line (ADMIT ONE): the type face at 24 px, leading none.
///
/// Mirrors `TicketTitle` in upstream `src/components/ui/ticket.tsx`.
class TicketTitle extends StatelessWidget {
  const TicketTitle(this.child, {super.key});

  /// The title, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.type,
        cssSize: 24,
        cssLineHeight: 1,
        color: theme.colors.ink,
      ),
      child: child,
    );
  }
}
