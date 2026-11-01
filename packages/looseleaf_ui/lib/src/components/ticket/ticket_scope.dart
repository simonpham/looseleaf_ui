import 'package:flutter/widgets.dart';

/// Tells a `TicketStub` how wide the ticket's stub is.
///
/// Mirrors `TicketContext` in upstream `src/components/ui/ticket.tsx`.
class TicketScope extends InheritedWidget {
  const TicketScope({super.key, required this.stubWidth, required super.child});

  /// The stub's width in px.
  final double stubWidth;

  /// The nearest ticket's stub width; upstream's 88 outside a ticket.
  static double stubWidthOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TicketScope>()?.stubWidth ??
      88;

  @override
  bool updateShouldNotify(TicketScope oldWidget) =>
      oldWidget.stubWidth != stubWidth;
}
