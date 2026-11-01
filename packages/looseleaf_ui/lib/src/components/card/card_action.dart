import 'package:flutter/widgets.dart';

/// A control at the top end of a [CardHeader] (a link, a button, a menu),
/// beside the title and description.
///
/// Mirrors `CardAction` in upstream `src/components/ui/card.tsx`.
class CardAction extends StatelessWidget {
  const CardAction({super.key, required this.child});

  /// The control.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
