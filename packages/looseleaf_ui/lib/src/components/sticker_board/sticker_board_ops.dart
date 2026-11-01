import 'dart:math' as math;
import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sticker_board/sticker_board.dart';

/// The pure edits behind a sticker board, usable on any item list: adding
/// a sticker, moving one through the stack, keeping one on the board.
///
/// Mirrors `addSticker`, `reorderSticker`, `keepIn` and `turnTo` in
/// upstream `src/components/ui/sticker-board.tsx`.
abstract final class StickerBoardOps {
  /// [deg] wrapped into (-180, 180], to a tenth of a degree.
  static double turnTo(double deg) {
    final a = JsMath.round(((((deg + 180) % 360) + 360) % 360) * 10) / 10 - 180;
    if (a == -180) return 180;
    return JsMath.round(a * 10) / 10;
  }

  /// [v] to two decimals.
  static double round2(double v) => JsMath.round(v * 100) / 100;

  static double _zOf(StickerBoardItem s) => switch (s.z.isFinite) {
    true => s.z,
    false => 0,
  };

  /// [items] with sticker [id] moved [how] through the stack, depths
  /// renumbered; the same list when nothing moved.
  static List<StickerBoardItem> reorder(
    List<StickerBoardItem> items,
    String id,
    StickerReorder how,
  ) {
    final sorted = [...items]..sort((a, b) => _zOf(a).compareTo(_zOf(b)));
    final i = sorted.indexWhere((s) => s.id == id);
    if (i < 0) return items;
    final it = sorted.removeAt(i);
    final to = switch (how) {
      StickerReorder.front => sorted.length,
      StickerReorder.back => 0,
      StickerReorder.forward => math.min(i + 1, sorted.length),
      StickerReorder.backward => math.max(i - 1, 0),
    };
    final relative =
        how == StickerReorder.forward || how == StickerReorder.backward;
    if (to == i && relative) return items;
    sorted.insert(to, it);
    final rank = {for (final (k, s) in sorted.indexed) s.id: k.toDouble()};
    final next = [for (final s in items) s.copyWith(z: rank[s.id] ?? s.z)];
    var same = true;
    for (final (k, s) in next.indexed) {
      if (s.z != items[k].z) same = false;
    }
    if (same) return items;
    return next;
  }

  /// [items] with sticker [name] added on top: at [x], [y] (or near the
  /// middle of [canvas], fanned out), turned [rot] degrees (seeded from the
  /// id when null), at [scale], as [id] when free (else `name-k`).
  static List<StickerBoardItem> add(
    List<StickerBoardItem> items,
    String name, {
    double? x,
    double? y,
    double? rot,
    double scale = 1,
    String? id,
    Size? canvas,
  }) {
    final used = {for (final s in items) s.id};
    var k = 1;
    while (used.contains('$name-$k')) {
      k++;
    }
    final newId = switch (id) {
      final wanted? when !used.contains(wanted) => wanted,
      _ => '$name-$k',
    };
    final cx = x ?? (canvas?.width ?? 320) / 2 + ((items.length % 5) - 2) * 18;
    final cy =
        y ?? (canvas?.height ?? 240) / 2 + ((items.length % 4) - 1.5) * 14;
    final turn =
        rot ?? JsMath.round(((hashSeed(newId) % 1600) / 100 - 8) * 10) / 10;
    final z = items.fold<double>(-1, (m, s) => math.max(m, _zOf(s))) + 1;
    return [
      ...items,
      StickerBoardItem(
        id: newId,
        name: name,
        x: JsMath.round(cx),
        y: JsMath.round(cy),
        rot: turn,
        scale: scale,
        z: z,
      ),
    ];
  }

  /// The centre ([x], [y]) kept on a [canvas] by [mode], for art of
  /// [art] size turned [rot] degrees at [scale].
  static Offset keepIn(
    double x,
    double y, {
    required Size art,
    required double rot,
    required double scale,
    required Size canvas,
    required StickerBoardBounds mode,
  }) {
    if (mode == StickerBoardBounds.none || canvas.isEmpty) return Offset(x, y);
    if (mode == StickerBoardBounds.center) {
      return Offset(x.clamp(0, canvas.width), y.clamp(0, canvas.height));
    }
    final a = rot * math.pi / 180;
    final c = math.cos(a).abs(), s = math.sin(a).abs();
    final ex = math.min(
      canvas.width / 2,
      (art.width * scale * c + art.height * scale * s) / 2,
    );
    final ey = math.min(
      canvas.height / 2,
      (art.width * scale * s + art.height * scale * c) / 2,
    );
    return Offset(
      x.clamp(ex, canvas.width - ex),
      y.clamp(ey, canvas.height - ey),
    );
  }
}
