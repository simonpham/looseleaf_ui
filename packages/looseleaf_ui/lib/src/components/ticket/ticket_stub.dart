import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/ticket/ticket_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The part of a ticket the doorman tears off: the ticket's `stubWidth`
/// wide, padded 8 × 12 px, its lines 4 px apart, centred both ways, in the
/// type face. A note beside the ticket for screen readers, not a landmark.
///
/// Named like upstream's part; the engine's side enum is `TicketStubSide`.
///
/// Mirrors `TicketStub` in upstream `src/components/ui/ticket.tsx`.
class TicketStub extends StatelessWidget {
  const TicketStub({super.key, required this.children});

  /// The lines, usually a big [TicketNumber].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      child: SizedBox(
        width: TicketScope.stubWidthOf(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d8,
            vertical: Spacing.d12,
          ),
          child: DefaultTextStyle.merge(
            style: theme.typography.face(
              KevinSansFace.type,
              color: theme.colors.ink,
            ),
            textAlign: TextAlign.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Spacing.d4,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
