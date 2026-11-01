import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/desk/desk.dart';

/// The desk the paper lies on: the desk colour, a linen weave and a lamp's
/// vignette behind [child], with optional [objects] (a coffee ring, a
/// pencil, clips, a ruler, pins) lying about under the paper.
///
/// The desk sizes to [child] plus [padding]; [lamp] scales the vignette
/// (0 for none).
///
/// ```dart
/// Desk(
///   objects: DeskObject.values,
///   padding: const EdgeInsets.all(Spacing.d48),
///   child: Card(children: [...]),
/// )
/// ```
///
/// Mirrors `Desk` in upstream `src/components/ui/desk.tsx`.
class Desk extends StatelessWidget {
  const Desk({
    super.key,
    this.objects = const [],
    this.lamp = 1,
    this.seed,
    this.padding = EdgeInsets.zero,
    this.child,
  });

  /// What lies on the desk; [DeskObject.values] for everything.
  final List<DeskObject> objects;

  /// How strong the lamp's vignette is; 0 turns it off.
  final double lamp;

  /// Pins the objects' drawings.
  final String? seed;

  /// Space around [child].
  final EdgeInsetsGeometry padding;

  /// The paper on the desk.
  final Widget? child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ExcludeSemantics(
          child: IgnorePointer(child: DeskBackground(lamp: lamp)),
        ),
      ),
      if (objects.isNotEmpty)
        Positioned.fill(
          child: DeskObjects(objects: objects, seed: seed),
        ),
      Padding(padding: padding, child: child ?? const SizedBox.shrink()),
    ],
  );
}
