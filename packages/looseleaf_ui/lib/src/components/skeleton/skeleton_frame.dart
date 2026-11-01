import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';

/// One boil frame of the skeleton's pencil tiles, parsed for painting: the
/// horizontal and vertical outline edges, the hatch and the round outline.
///
/// Upstream ships these as CSS mask images (`skeletonCss` in
/// `src/lib/ink/recipes/skeleton-ink.ts`); here the same tile markup is
/// painted directly.
class SkeletonFrame {
  SkeletonFrame._(SkeletonTiles tiles)
    : edgeH = _document(tiles.edgeH),
      edgeV = _document(tiles.edgeV),
      hatch = _document(tiles.hatch),
      circle = _document(tiles.circle);

  /// The frames, drawn on first use.
  static final List<SkeletonFrame> all = List.unmodifiable([
    for (var frame = 0; frame < skeletonFrames; frame++)
      SkeletonFrame._(skeletonTiles(frame)),
  ]);

  /// An [edgeLen] × [edgeTh] pencil rule.
  final InkDocument edgeH;

  /// An [edgeTh] × [edgeLen] pencil rule.
  final InkDocument edgeV;

  /// A seamless [hatchSize] square of hatching.
  final InkDocument hatch;

  /// A [circleSize] square pencil circle.
  final InkDocument circle;

  static const String _prefix = 'url("data:image/svg+xml,';

  /// The markup inside a tile's `url("data:image/svg+xml,…")` `<svg>`.
  static InkDocument _document(String url) {
    final svg = Uri.decodeComponent(
      url.substring(_prefix.length, url.length - 2),
    );
    final body = svg.substring(svg.indexOf('>') + 1, svg.lastIndexOf('</svg>'));
    return InkDocument.parse(body);
  }
}
