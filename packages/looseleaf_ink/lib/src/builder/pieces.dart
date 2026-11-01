import 'package:looseleaf_ink/src/core/core.dart';

/// A node of the emitted SVG tree.
///
/// Mirrors `Piece` in `src/lib/ink/builder.ts`.
sealed class Piece {}

/// Raw markup.
final class RawPiece extends Piece {
  /// Raw markup.
  RawPiece(this.s);

  final String s;
}

/// A material group: a grain mask and/or blend mode around its kids.
final class MatPiece extends Piece {
  /// A material group.
  MatPiece({required this.grain, required this.blend, required this.kids});

  final GrainKind? grain;
  final bool blend;
  List<Piece> kids;

  /// A shallow copy.
  MatPiece copy() => MatPiece(grain: grain, blend: blend, kids: kids);
}

/// A user group (`Ink.group`): a clip path prefix, the open tag and kids.
final class GroupPiece extends Piece {
  /// A group.
  GroupPiece({
    required this.pre,
    required this.open,
    required this.kids,
    required this.plain,
  });

  final String pre;
  final String open;
  final List<Piece> kids;

  /// No clip, transform, opacity, id or mask: safe to merge into grain runs.
  final bool plain;

  /// A copy with other kids.
  GroupPiece withKids(List<Piece> kids) =>
      GroupPiece(pre: pre, open: open, kids: kids, plain: plain);
}
