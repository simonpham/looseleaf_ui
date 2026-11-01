import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_options.dart';

/// Throws bursts on the [Confetti] layer it is given to (upstream's
/// `apiRef` handle). Before it is attached, [burst] does nothing.
class ConfettiController {
  ConfettiController();

  VoidCallback Function(ConfettiOptions? options)? _burst;

  /// Whether a [Confetti] layer is using this controller.
  bool get attached => _burst != null;

  /// Throws a burst with the layer's options and [options] over them, and
  /// returns a function that stops it early.
  VoidCallback burst([ConfettiOptions? options]) {
    final burst = _burst;
    if (burst == null) return () {};
    return burst(options);
  }

  /// Connects a layer; for [Confetti] itself.
  void attach(VoidCallback Function(ConfettiOptions? options) burst) {
    _burst = burst;
  }

  /// Disconnects [burst] if it is the attached layer's.
  void detach(VoidCallback Function(ConfettiOptions? options) burst) {
    if (_burst == burst) _burst = null;
  }
}
