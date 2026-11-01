import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/stocks.dart';
import 'package:looseleaf_ink/src/textures/paper_tiles.dart';

/// The CSS colour of each named paper stock.
///
/// Mirrors `PAPER_STOCKS` in `src/lib/ink/textures.ts`.
const Map<String, String> paperStocks = {
  'paper': 'var(--ll-paper)',
  'slip': 'var(--ll-slip)',
  'card': 'var(--ll-card)',
  'graph': 'var(--ll-graph)',
  'check': 'var(--ll-check)',
  'kraft': 'var(--ll-kraft)',
  'yellow': 'var(--ll-sticky-yellow)',
  'green': 'var(--ll-sticky-green)',
  'orange': 'var(--ll-sticky-orange)',
  'pink': 'var(--ll-sticky-pink)',
  'blue': 'var(--ll-sticky-blue)',
};

/// A CSS background: colour and tiled image layers.
///
/// Mirrors `TextureStyle` in `src/lib/ink/textures.ts`.
final class TextureStyle {
  /// A background.
  const TextureStyle({
    required this.backgroundColor,
    required this.backgroundImage,
    required this.backgroundSize,
    required this.backgroundPosition,
    required this.backgroundRepeat,
  });

  /// `background-color`.
  final String backgroundColor;

  /// `background-image`.
  final String backgroundImage;

  /// `background-size`.
  final String backgroundSize;

  /// `background-position`.
  final String backgroundPosition;

  /// `background-repeat`.
  final String backgroundRepeat;

  /// As inline CSS declarations.
  ///
  /// Mirrors `styleToCss` in `src/lib/ink/textures.ts`.
  String toCss() =>
      'background-color:$backgroundColor;background-image:$backgroundImage;'
      'background-size:$backgroundSize;background-position:$backgroundPosition;'
      'background-repeat:$backgroundRepeat';
}

int _hash32(String s) {
  var h = 0x811c9dc5;
  for (var i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    h = JsMath.imul(h, 0x01000193);
  }
  h ^= h >> 16;
  h = JsMath.imul(h, 0x85ebca6b);
  h ^= h >> 13;
  return h & 0xFFFFFFFF;
}

String _seedText(Object seed) => switch (seed) {
  final num v => JsMath.numberToString(v),
  _ => seed.toString(),
};

String _offsetFor(Object? seed, int i, double w, double h) {
  if (seed == null) return '0 0';
  final a = _hash32('${_seedText(seed)}:$i');
  final x = a % JsMath.roundInt(w);
  final y = (a >> 11) % JsMath.roundInt(h);
  return '${-x}px ${-y}px';
}

String _size(PaperTileName t) =>
    '${JsMath.numberToString(t.cssWidth)}px ${JsMath.numberToString(t.cssHeight)}px';

/// A paper background for [stock] (a [paperStocks] name or any CSS
/// colour): fibre, relief or slip tooth, cloud and kraft tiles, offset by
/// [seed]; [layers] turns tiles on or off. Tile images come from [uri].
///
/// Mirrors `paperBackground` in `src/lib/ink/textures.ts`.
TextureStyle paperBackground(
  TileUri uri, {
  String stock = 'paper',
  Tooth? tooth,
  Object? seed,
  Map<PaperTileName, bool> layers = const {},
}) {
  final fallback = switch (stock == 'paper') {
    true => Tooth.cold,
    false => Tooth.fine,
  };
  final cold = (tooth ?? fallback) == Tooth.cold;
  final kraft = stock == 'kraft';
  final on = <PaperTileName, bool>{
    PaperTileName.relief: cold && !kraft,
    PaperTileName.slip: !cold && !kraft,
    PaperTileName.fibre: true,
    PaperTileName.cloud: true,
    PaperTileName.kraft: kraft,
    ...layers,
  };
  final tiles = [
    for (final t in const [
      PaperTileName.fibre,
      PaperTileName.kraft,
      PaperTileName.relief,
      PaperTileName.slip,
      PaperTileName.cloud,
    ])
      if (on[t] ?? false) t,
  ];
  return TextureStyle(
    backgroundColor: paperStocks[stock] ?? stock,
    backgroundImage: tiles.map((t) => 'url(${uri(t.name)})').join(', '),
    backgroundSize: tiles.map(_size).join(', '),
    backgroundPosition: [
      for (final (i, t) in tiles.indexed)
        _offsetFor(seed, i, t.cssWidth, t.cssHeight),
    ].join(', '),
    backgroundRepeat: tiles.map((_) => 'repeat').join(', '),
  );
}

/// The desk background: linen tiles under a [vignette].
///
/// Mirrors `deskBackground` in `src/lib/ink/textures.ts`.
TextureStyle deskBackground(
  TileUri uri, {
  double vignette = 0.05,
  Object? seed,
}) {
  final vig =
      'radial-gradient(ellipse 92% 82% at 50% 40%, rgb(var(--ll-shade) / 0) 52%, rgb(var(--ll-shade) / ${JsMath.numberToString(vignette)}) 100%)';
  const linen = PaperTileName.linen;
  return TextureStyle(
    backgroundColor: 'var(--ll-desk)',
    backgroundImage: '$vig, url(${uri(linen.name)})',
    backgroundSize: '100% 100%, ${_size(linen)}',
    backgroundPosition:
        '0 0, ${_offsetFor(seed, 0, linen.cssWidth, linen.cssHeight)}',
    backgroundRepeat: 'no-repeat, repeat',
  );
}

/// [paperBackground] as inline CSS.
///
/// Mirrors `paperCss` in `src/lib/ink/textures.ts`.
String paperCss(
  TileUri uri, {
  String stock = 'paper',
  Tooth? tooth,
  Object? seed,
  Map<PaperTileName, bool> layers = const {},
}) => paperBackground(
  uri,
  stock: stock,
  tooth: tooth,
  seed: seed,
  layers: layers,
).toCss();

/// [deskBackground] as inline CSS.
///
/// Mirrors `deskCss` in `src/lib/ink/textures.ts`.
String deskCss(TileUri uri, {double vignette = 0.05, Object? seed}) =>
    deskBackground(uri, vignette: vignette, seed: seed).toCss();

/// A `:root` rule defining `--ll-tex-<name>` for each tile.
///
/// Mirrors `textureCssVars` in `src/lib/ink/textures.ts`.
String textureCssVars(
  TileUri uri, [
  List<PaperTileName> names = PaperTileName.values,
]) =>
    ':root{${names.map((t) => '--ll-tex-${t.name}:url(${uri(t.name)})').join(';')}}';
