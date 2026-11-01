import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The part of a ticket you keep: it takes the room the stub leaves,
/// padded 24 × 16 px inside the printed frame, its lines 4 px apart and
/// centred top to bottom, in the type face. Use it as a direct child of a
/// `Ticket`.
///
/// Mirrors `TicketBody` in upstream `src/components/ui/ticket.tsx`.
class TicketBody extends StatelessWidget {
  const TicketBody({
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.children,
  });

  /// How the lines line up across: start, or centre for a stub-less ticket.
  final CrossAxisAlignment crossAxisAlignment;

  /// The lines: [TicketTitle], [TicketDescription], [TicketNumber], …
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d24,
          vertical: Spacing.d16,
        ),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.type,
            color: theme.colors.ink,
          ),
          textAlign: switch (crossAxisAlignment) {
            CrossAxisAlignment.center => TextAlign.center,
            _ => TextAlign.start,
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: crossAxisAlignment,
            spacing: Spacing.d4,
            children: children,
          ),
        ),
      ),
    );
  }
}
