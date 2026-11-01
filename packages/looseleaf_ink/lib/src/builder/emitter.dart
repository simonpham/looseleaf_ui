import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';

const Map<Material, GrainKind> _grainOf = {
  Material.marker: GrainKind.marker,
  Material.pencil: GrainKind.graphite,
  Material.waxy: GrainKind.waxy,
  Material.text: GrainKind.felt,
  Material.felt: GrainKind.felt,
  Material.stamp: GrainKind.stamp,
};
const Set<Material> _blended = {Material.hl, Material.marker};
const Set<GrainKind> _subtle = {GrainKind.marker, GrainKind.felt};

/// Turns a [Scope] into SVG markup: merges same-paint paths, wraps material
/// buckets in grain masks and blend groups, and (when lean) merges runs of
/// subtle grains into one mask.
///
/// Mirrors the emit half of `Ink` in `src/lib/ink/builder.ts`.
final class InkEmitter {
  /// An emitter for one drawing.
  const InkEmitter({
    required this.tier,
    required this.grain,
    required this.leaned,
    required this.variant,
  });

  final Tier tier;
  final bool grain;
  final bool leaned;
  final int variant;

  /// The markup of [scope].
  String emit(Scope scope) {
    var nodes = _scopeNodes(scope);
    if (leaned && grain) nodes = _leanMerge(nodes);
    return _print(_join(nodes));
  }

  List<Piece> _itemNodes(List<Item> items) {
    final q = switch (tier) {
      Tier.lo => 50,
      Tier.hi => 100,
    };
    final merged = <String, PathItem>{};
    final seq = <Object>[];
    for (final it in items) {
      switch (it) {
        case RawItem(:final raw):
          seq.add(RawPiece(raw));
        case ScopeItem(:final scope):
          seq.add(_groupNode(scope));
        case PathItem() when it.evenOdd || it.stroke != null:
          seq.add(it);
        case PathItem():
          final op = JsMath.round(it.op * q) / q;
          final key = '${it.fill.id}|$op|${it.clip ?? ''}';
          if (merged[key] case final m?) {
            m.d += it.d;
            continue;
          }
          final c = it.withOp(op);
          merged[key] = c;
          seq.add(c);
      }
    }
    return [for (final it in seq) _pathNode(it)];
  }

  Piece _pathNode(Object it) {
    if (it is! PathItem) return it as Piece;
    final op = n(it.op, 100);
    final clip = switch (it.clip) {
      final String id when id.isNotEmpty => ' clip-path="url(#$id)"',
      _ => '',
    };
    final translucent = it.op < 0.995;
    if (it.stroke case final stroke?) {
      final opacity = switch (translucent) {
        true => ' stroke-opacity="$op"',
        false => '',
      };
      return RawPiece(
        '<path d="${it.d}" fill="none" stroke="${paint(stroke)}" stroke-width="${n(it.sw ?? 1)}" '
        'stroke-linecap="round" stroke-linejoin="round"$opacity$clip/>',
      );
    }
    final opacity = switch (translucent) {
      true => ' fill-opacity="$op"',
      false => '',
    };
    final rule = switch (it.evenOdd) {
      true => ' fill-rule="evenodd"',
      false => '',
    };
    return RawPiece(
      '<path d="${it.d}" fill="${paint(it.fill)}"$opacity$rule$clip/>',
    );
  }

  List<Piece> _scopeNodes(Scope scope) {
    final out = <Piece>[];
    for (final mat in Material.values) {
      final items = scope.buckets[mat];
      if (items == null || items.isEmpty) continue;
      final kids = _itemNodes(items);
      final grainKind = switch (grain) {
        true => _grainOf[mat],
        false => null,
      };
      final blend = _blended.contains(mat);
      if (grainKind == null && !blend) {
        out.addAll(kids);
        continue;
      }
      out.add(MatPiece(grain: grainKind, blend: blend, kids: kids));
    }
    return out;
  }

  Piece _groupNode(Scope scope) {
    final a = scope.attrs ?? GroupAttrs();
    final kids = _scopeNodes(scope);
    var pre = '';
    var attrs = '';
    final clip = a.clip ?? '';
    if (clip.isNotEmpty) {
      final id = 'll-c${hashSeed(clip).toRadixString(36)}';
      pre = '<clipPath id="$id"><path d="$clip"/></clipPath>';
      attrs += ' clip-path="url(#$id)"';
    }
    final transform = a.transform ?? '';
    if (transform.isNotEmpty) attrs += ' transform="$transform"';
    final opacity = a.opacity;
    final faded = opacity != null && opacity < 1;
    if (faded) attrs += ' opacity="${n(opacity, 100)}"';
    final id = a.id ?? '';
    if (id.isNotEmpty) attrs += ' id="${esc(id)}"';
    final part = a.part ?? '';
    if (part.isNotEmpty) attrs += ' data-part="${esc(part)}"';
    final hideOn = a.hideOn ?? '';
    if (hideOn.isNotEmpty) attrs += ' data-hide-on="${esc(hideOn)}"';
    final mask = a.mask ?? '';
    if (mask.isNotEmpty) attrs += ' mask="url(#${esc(mask)})"';
    if (a.vars case final vars?) {
      attrs +=
          ' style="${vars.entries.map((e) => '--${e.key}:${n(e.value)}').join(';')}"';
    }
    final plain =
        clip.isEmpty &&
        transform.isEmpty &&
        !faded &&
        id.isEmpty &&
        mask.isEmpty;
    return GroupPiece(pre: pre, open: '<g$attrs>', kids: kids, plain: plain);
  }

  static bool _isSubtle(Piece nd) =>
      nd is MatPiece &&
      _subtle.contains(nd.grain) &&
      nd.kids.every((k) => k is RawPiece);

  static bool _isPure(Piece nd) =>
      nd is GroupPiece &&
      nd.plain &&
      nd.pre.isEmpty &&
      nd.kids.isNotEmpty &&
      nd.kids.every((k) => _isSubtle(k) || _isPure(k));

  static List<Piece> _bare(Piece nd) => switch (nd) {
    MatPiece(:final kids) => kids,
    GroupPiece() => [
      nd.withKids([for (final k in nd.kids) ..._bare(k)]),
    ],
    RawPiece() => [nd],
  };

  static void _grainsIn(Piece nd, List<(GrainKind?, bool)> into) {
    switch (nd) {
      case MatPiece(:final grain, :final blend):
        into.add((grain, blend));
      case GroupPiece(:final kids):
        for (final k in kids) {
          _grainsIn(k, into);
        }
      case RawPiece():
        return;
    }
  }

  List<Piece> _leanMerge(List<Piece> nodes) {
    final out = <Piece>[];
    var run = <Piece>[];
    void flush() {
      if (run.length < 2) {
        out.addAll(run);
        run = [];
        return;
      }
      final found = <(GrainKind?, bool)>[];
      for (final r in run) {
        _grainsIn(r, found);
      }
      final grain = switch (found.any((f) => f.$1 == GrainKind.marker)) {
        true => GrainKind.marker,
        false => GrainKind.felt,
      };
      out.add(
        MatPiece(
          grain: grain,
          blend: found.any((f) => f.$2),
          kids: [for (final r in run) ..._bare(r)],
        ),
      );
      run = [];
    }

    for (final nd in nodes) {
      if (_isSubtle(nd) || _isPure(nd)) {
        run.add(nd);
        continue;
      }
      flush();
      out.add(switch (nd) {
        GroupPiece() => nd.withKids(_leanMerge(nd.kids)),
        _ => nd,
      });
    }
    flush();
    return out;
  }

  static List<Piece> _join(List<Piece> nodes) {
    final out = <Piece>[];
    for (final nd in nodes) {
      final last = switch (out) {
        [..., final tail] => tail,
        _ => null,
      };
      if (nd is MatPiece &&
          last is MatPiece &&
          last.grain == nd.grain &&
          last.blend == nd.blend) {
        last.kids = [...last.kids, ...nd.kids];
        continue;
      }
      out.add(switch (nd) {
        MatPiece() => nd.copy(),
        _ => nd,
      });
    }
    return [
      for (final nd in out)
        switch (nd) {
          GroupPiece() => nd.withKids(_join(nd.kids)),
          _ => nd,
        },
    ];
  }

  String _print(List<Piece> nodes) {
    final out = StringBuffer();
    for (final nd in nodes) {
      switch (nd) {
        case RawPiece(:final s):
          out.write(s);
        case GroupPiece(:final pre, :final open, :final kids):
          out.write('$pre$open${_print(kids)}</g>');
        case MatPiece(:final grain, blend: final blended, :final kids):
          final mask = switch (grain) {
            final GrainKind g => ' mask="url(#${maskId(g, variant)})"',
            null => '',
          };
          final style = switch (blended) {
            true => ' style="mix-blend-mode:$blend"',
            false => '',
          };
          out.write('<g$mask$style>${_print(kids)}</g>');
      }
    }
    return out.toString();
  }
}
