import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' show boilSeed;

/// The current boil frame, provided by a [Boil] to the ink below it.
///
/// Mirrors upstream `BoilContext` (`src/components/ui/boil.tsx`).
class BoilScope extends InheritedWidget {
  const BoilScope({
    super.key,
    required this.frame,
    required this.frames,
    required super.child,
  });

  /// The frame shown, 0 when still.
  final int frame;

  /// How many frames the boil cycles through.
  final int frames;

  /// The frame of the nearest [Boil], 0 outside one (upstream
  /// `useBoilFrame`).
  static int frameOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BoilScope>()?.frame ?? 0;

  /// [base] reseeded for the current frame, unchanged on frame 0 (upstream
  /// `useBoilSeed`).
  static String seedOf(BuildContext context, String base) =>
      boilSeed(base, frameOf(context));

  @override
  bool updateShouldNotify(BoilScope oldWidget) =>
      oldWidget.frame != frame || oldWidget.frames != frames;
}
