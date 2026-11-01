import 'package:looseleaf_ink/src/art/model/model.dart';

/// The kind of [def]: its own, or icon for the 24 grid, mascot for a
/// `[w, h]` grid and doodle otherwise.
///
/// Mirrors `kindOfDef` in `src/lib/ink/art/dsl.ts`.
ArtKind kindOfDef(ArtDef def) {
  if (def.kind case final kind?) return kind;
  if (def.grid.pair) return ArtKind.mascot;
  if (def.grid.w == 24) return ArtKind.icon;
  return ArtKind.doodle;
}
