import 'dart:convert';

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/shadows.dart';
import 'package:looseleaf_ink/src/paper/stocks.dart';

/// A piece of sheet markup: plain SVG ([FaceMarkup]) or a paper face
/// ([FaceSpec]) to draw behind the ink.
sealed class FacePiece {
  const FacePiece();
}

/// Plain SVG markup between faces.
final class FaceMarkup extends FacePiece {
  /// Markup.
  const FaceMarkup(this.markup);

  /// The SVG markup.
  final String markup;
}

/// The shadow a face casts: its kind, the sheet's insets
/// `[top, right, bottom, left]` and optional corner radii.
///
/// Mirrors `FaceSpec['cast']` in `src/lib/ink/paper/faces.ts`.
final class FaceCast {
  /// A cast shadow.
  const FaceCast({required this.kind, required this.inset, this.radius});

  /// The shadow.
  final SheetShadowKind kind;

  /// Insets of the shadow box, `[top, right, bottom, left]`.
  final List<double> inset;

  /// Corner radii, `[tl, tr, br, bl]`; when set, every layer is cast.
  final List<double>? radius;
}

/// A paper face: a clip path filled with a stock's colour, tooth tiles and
/// sheen, plus the shadow it casts.
///
/// Upstream emits this as a `<!--ll-face:{…}-->` comment that the page
/// renders with CSS; here it is typed so a painter can draw it directly.
///
/// Mirrors `FaceSpec` in `src/lib/ink/paper/faces.ts`.
final class FaceSpec extends FacePiece {
  /// A face.
  const FaceSpec({
    required this.d,
    required this.stock,
    required this.seed,
    this.evenodd = false,
    this.veil = true,
    this.paper = true,
    this.cast,
  });

  /// Reads the JSON object of a face mark.
  factory FaceSpec.fromJson(Map<String, dynamic> json) {
    final cast = switch (json['cast']) {
      final Map<String, dynamic> c => FaceCast(
        kind: SheetShadowKind.values.byName(c['kind'] as String),
        inset: _doubles(c['inset']),
        radius: switch (c['radius']) {
          final List<dynamic> r => _doubles(r),
          _ => null,
        },
      ),
      _ => null,
    };
    return FaceSpec(
      d: json['d'] as String,
      stock: StockName.byId(json['stock'] as String?) ?? StockName.paper,
      seed: (json['seed'] as num).toInt(),
      evenodd: json['evenodd'] == true,
      veil: json['veil'] != false,
      paper: json['paper'] != false,
      cast: cast,
    );
  }

  /// The clip path, in the drawing's coordinates.
  final String d;

  /// Whether [d] fills even-odd (a sheet with holes).
  final bool evenodd;

  /// The stock.
  final StockName stock;

  /// The seed for tile offsets and ids.
  final int seed;

  /// False to skip a sticky note's gum veil.
  final bool veil;

  /// False for a shadow-only mark with no paper.
  final bool paper;

  /// The shadow, if the face casts one.
  final FaceCast? cast;

  /// The JSON upstream writes, keys in upstream order.
  String toJsonString() {
    final parts = <String>[
      '"d":${jsonEncode(d)}',
      '"stock":${jsonEncode(stock.id)}',
      '"seed":${_num(seed)}',
      if (!veil) '"veil":false',
      if (evenodd) '"evenodd":true',
      if (!paper) '"paper":false',
      if (cast case final c?) '"cast":${_castJson(c)}',
    ];
    return '{${parts.join(',')}}';
  }
}

List<double> _doubles(Object? v) => [
  for (final x in v as List<dynamic>) (x as num).toDouble(),
];

String _num(num v) => switch (v.isFinite) {
  true => JsMath.numberToString(v),
  false => 'null',
};

String _list(List<double> v) => '[${v.map(_num).join(',')}]';

String _castJson(FaceCast c) {
  final parts = <String>[
    '"kind":${jsonEncode(c.kind.name)}',
    '"inset":${_list(c.inset)}',
    if (c.radius case final r?) '"radius":${_list(r)}',
  ];
  return '{${parts.join(',')}}';
}

/// The comment that marks a face in ink markup.
///
/// Mirrors `faceMark` in `src/lib/ink/paper/faces.ts`.
String faceMark(FaceSpec spec) =>
    '<!--ll-face:${spec.toJsonString().replaceAll('--', r'-\u002d')}-->';

/// A shadow-only face mark.
///
/// Mirrors `shadowMark` in `src/lib/ink/paper/faces.ts`.
String shadowMark(
  SheetShadowKind kind,
  List<double> radius, [
  List<double> inset = const [0, 0, 0, 0],
]) => faceMark(
  FaceSpec(
    d: 'M0 0',
    stock: StockName.paper,
    seed: 0,
    paper: false,
    cast: FaceCast(kind: kind, inset: inset, radius: radius),
  ),
);

final RegExp _mark = RegExp('<!--ll-face:(.*?)-->', dotAll: true);

/// Splits [markup] into plain markup and faces, in order.
///
/// Mirrors `splitFaces` in `src/lib/ink/paper/faces.ts`.
List<FacePiece> splitFaces(String markup) {
  final out = <FacePiece>[];
  var last = 0;
  for (final m in _mark.allMatches(markup)) {
    if (m.start > last) out.add(FaceMarkup(markup.substring(last, m.start)));
    out.add(
      FaceSpec.fromJson(jsonDecode(m.group(1) ?? '{}') as Map<String, dynamic>),
    );
    last = m.end;
  }
  if (last < markup.length) out.add(FaceMarkup(markup.substring(last)));
  return out;
}

/// Whether [markup] holds a face mark.
///
/// Mirrors `hasFace` in `src/lib/ink/paper/faces.ts`.
bool hasFace(String markup) => markup.contains('<!--ll-face:');
