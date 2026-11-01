import 'package:looseleaf_ink/src/art/model/art_def.dart';
import 'package:looseleaf_ink/src/art/model/art_enums.dart';
import 'package:looseleaf_ink/src/art/model/art_part.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// One layer of a scene: another piece of art (`icon:`, `doodle:`,
/// `sticker:`, `mascot:`, `mascot-prop:`, `prop:`) or loose `ink` parts,
/// placed by its centre.
///
/// Mirrors `SceneLayer` in `src/lib/ink/art/scenes/empty-scenes.ts`.
final class SceneLayer {
  /// A layer.
  const SceneLayer({
    required this.ref,
    required this.at,
    required this.size,
    this.rot,
    this.flip,
    this.aspect,
    this.edge,
    this.tone,
    this.rules,
    this.accent,
    this.nib,
    this.peel,
    this.hi,
    this.parts,
    this.note,
  });

  /// What to draw, `kind:id` or `ink`.
  final String ref;

  /// The centre on the scene grid.
  final Pt at;

  /// The size on the scene grid.
  final double size;

  /// Rotation in degrees.
  final double? rot;

  /// Mirrored.
  final bool? flip;

  /// Width over height, for paper props.
  final double? aspect;

  /// Paper edge style.
  final String? edge;

  /// Paper tone.
  final String? tone;

  /// Paper rules.
  final SceneRules? rules;

  /// Accent override.
  final ArtAccent? accent;

  /// Nib override.
  final double? nib;

  /// A peeled corner.
  final bool? peel;

  /// Highlight.
  final bool? hi;

  /// Parts of an `ink` layer.
  final List<ArtPart>? parts;

  /// An author note.
  final String? note;
}

/// An empty-state scene: its own parts plus layers of other art.
///
/// Mirrors `SceneDef` in `src/lib/ink/art/scenes/empty-scenes.ts`.
final class SceneDef extends ArtDef {
  /// A scene.
  const SceneDef({
    required super.grid,
    required super.parts,
    required this.layers,
    this.layersSmall,
    super.small,
    super.micro,
    super.hi,
    super.accent,
    super.nibK,
    super.tags,
    super.shade,
    super.tilt,
  }) : super(kind: ArtKind.scene);

  /// The layers, bottom first.
  final List<SceneLayer> layers;

  /// Simpler layers for small sizes.
  final List<SceneLayer>? layersSmall;
}
