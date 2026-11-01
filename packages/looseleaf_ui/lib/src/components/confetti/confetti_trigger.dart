import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_options.dart';
import 'package:looseleaf_ui/src/components/confetti/show_confetti.dart';

/// Builds a control that throws confetti from itself: [builder] gets a
/// `burst` callback to wire to the control's press, and the burst leaves
/// from the control's center over the whole screen.
///
/// ```dart
/// ConfettiTrigger(
///   options: const ConfettiOptions(spread: 360, velocity: 700),
///   builder: (context, burst) => Button(
///     onPressed: burst,
///     child: const Text('Celebrate'),
///   ),
/// )
/// ```
///
/// Mirrors `ConfettiTrigger` in upstream `src/components/ui/confetti.tsx`
/// (its `asChild` form).
class ConfettiTrigger extends StatelessWidget {
  const ConfettiTrigger({
    super.key,
    required this.builder,
    this.options = const ConfettiOptions(),
  });

  /// Builds the control; call `burst` when it is pressed.
  final Widget Function(BuildContext context, VoidCallback burst) builder;

  /// How the burst flies; its origin defaults to the control's center.
  final ConfettiOptions options;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (context) => builder(context, () {
      final box = context.findRenderObject();
      final center = switch (box) {
        RenderBox(hasSize: true) => box.localToGlobal(
          box.size.center(Offset.zero),
        ),
        _ => null,
      };
      showConfetti(
        context,
        ConfettiOptions(origin: center).merge(options),
      );
    }),
  );
}
