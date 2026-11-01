import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_controller.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_options.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_widget.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Throws a burst of confetti over the whole screen, in the nearest
/// [Overlay], and returns a function that stops it early. The burst leaves
/// from [ConfettiOptions.origin], else the center of the screen; the layer
/// is removed once every piece has landed. Reduced motion throws nothing.
///
/// ```dart
/// showConfetti(context, const ConfettiOptions(spread: 360, count: 90));
/// ```
///
/// Mirrors `confetti()` in upstream `src/components/ui/confetti.tsx`.
VoidCallback showConfetti(
  BuildContext context, [
  ConfettiOptions options = const ConfettiOptions(),
]) {
  if (InkMotion.reducedIn(context)) return () {};
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return () {};
  final controller = ConfettiController();
  late final OverlayEntry entry;
  var removed = false;
  void remove() {
    if (removed) return;
    removed = true;
    entry.remove();
    entry.dispose();
  }

  entry = OverlayEntry(
    builder: (context) => Confetti(controller: controller),
  );
  overlay.insert(entry);
  var stop = remove;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (removed) return;
    final cancel = controller.burst(
      options.merge(
        ConfettiOptions(
          onDone: () {
            options.onDone?.call();
            SchedulerBinding.instance.addPostFrameCallback((_) => remove());
          },
        ),
      ),
    );
    stop = () {
      cancel();
      remove();
    };
  });
  return () => stop();
}
