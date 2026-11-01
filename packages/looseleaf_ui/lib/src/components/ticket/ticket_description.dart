import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A ticket's place and time: the type face at 14 px.
///
/// Mirrors `TicketDescription` in upstream `src/components/ui/ticket.tsx`.
class TicketDescription extends StatelessWidget {
  const TicketDescription(this.child, {super.key});

  /// The description, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.type,
        cssSize: 14,
        cssLineHeight: 20 / 14,
        color: theme.colors.ink,
      ),
      child: child,
    );
  }
}
