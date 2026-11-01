import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/edges.dart';
import 'package:looseleaf_ink/src/paper/rules.dart';
import 'package:looseleaf_ink/src/paper/shadows.dart';
import 'package:looseleaf_ink/src/textures/paper_tiles.dart';

/// A paper stock.
///
/// Mirrors `StockName` in `src/lib/ink/paper/stocks.ts`.
enum StockName {
  paper('paper'),
  card('card'),
  slip('slip'),
  indexCard('index-card'),
  graph('graph'),
  dotGrid('dot-grid'),
  check('check'),
  ledger('ledger'),
  pad('pad'),
  kraft('kraft'),
  napkin('napkin'),
  stickyYellow('sticky-yellow'),
  stickyGreen('sticky-green'),
  stickyOrange('sticky-orange'),
  stickyPink('sticky-pink'),
  stickyBlue('sticky-blue'),
  photo('photo'),
  parchment('parchment'),
  receipt('receipt');

  const StockName(this.id);

  /// The upstream name, e.g. `index-card`.
  final String id;

  /// The stock named [id], or null.
  static StockName? byId(String? id) {
    for (final s in values) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// How much a sticky note's gum veil covers (`STICKY_VEIL`).
const double stickyVeil = 0.45;

/// The paper tooth (surface texture).
///
/// Mirrors `Tooth` in `src/lib/ink/paper/stocks.ts`.
enum Tooth {
  cold('ll-tooth-cold'),
  fine('ll-tooth-fine'),
  kraft('ll-tooth-kraft'),
  none('');

  const Tooth(this.className);

  /// The CSS class (`TOOTH_CLASS`), empty for `none`.
  final String className;
}

/// A stock's look: paint tokens, texture, shadow, edge, rules and tilt.
///
/// Mirrors `StockDef` in `src/lib/ink/paper/stocks.ts`.
final class StockDef {
  /// A stock.
  const StockDef({
    required this.name,
    required this.label,
    required this.color,
    required this.base,
    required this.stockClass,
    required this.tooth,
    required this.shadow,
    required this.shadowClass,
    required this.edge,
    required this.rules,
    required this.tilt,
    this.tint,
    this.gum = false,
  });

  /// The stock.
  final StockName name;

  /// A display label.
  final String label;

  /// The CSS colour: `var(--ll-<base>)`, or a `color-mix` with the tint.
  final String color;

  /// The base paint token.
  final String base;

  /// A paint token mixed in, and its share.
  final (String, double)? tint;

  /// The CSS class of the stock, or empty.
  final String stockClass;

  /// The tooth.
  final Tooth tooth;

  /// The tooth's CSS class.
  String get toothClass => tooth.className;

  /// The shadow.
  final SheetShadowKind shadow;

  /// The shadow's CSS class, or empty.
  final String shadowClass;

  /// The edges.
  final EdgeSpec edge;

  /// The printed rules.
  final RuleName rules;

  /// The largest resting tilt, in degrees.
  final double tilt;

  /// Whether it is a sticky note (gum strip, veil).
  final bool gum;
}

const Map<String, String> _tokenOf = {
  'card': 'paper',
  'napkin': 'paper',
  'index-card': 'card',
  'dot-grid': 'graph',
  'ledger': 'check',
  'receipt': 'photo',
};

StockDef _def(
  StockName name,
  String label,
  String stockClass,
  Tooth tooth,
  SheetShadowKind shadow,
  String shadowClass,
  EdgeSpec edge,
  RuleName rules,
  double tilt, {
  String? base,
  (String, double)? tint,
  bool gum = false,
}) {
  final b = base ?? name.id;
  final baseVar = _tokenOf[b] ?? b;
  final color = switch (tint) {
    (final token, final share) =>
      'color-mix(in srgb, var(--ll-$token) ${JsMath.roundInt(share * 100)}%, var(--ll-$baseVar))',
    null => 'var(--ll-$baseVar)',
  };
  return StockDef(
    name: name,
    label: label,
    color: color,
    base: baseVar,
    tint: tint,
    stockClass: stockClass,
    tooth: tooth,
    shadow: shadow,
    shadowClass: shadowClass,
    edge: edge,
    rules: rules,
    tilt: tilt,
    gum: gum,
  );
}

const EdgeSpec _cut = EdgeSpec.all(EdgeKind.cut);

StockDef _sticky(StockName name, String label) => _def(
  name,
  label,
  'll-stock-${name.id}',
  Tooth.fine,
  SheetShadowKind.sticky,
  'll-sheet-sticky',
  _cut,
  RuleName.none,
  1.6,
  gum: true,
);

StockDef _stock(StockName name) => switch (name) {
  StockName.paper => _def(
    name,
    'Paper',
    'll-stock-paper',
    Tooth.cold,
    SheetShadowKind.paper,
    '',
    _cut,
    RuleName.none,
    0.6,
  ),
  StockName.card => _def(
    name,
    'Card',
    'll-stock-paper',
    Tooth.cold,
    SheetShadowKind.card,
    'll-sheet-card',
    _cut,
    RuleName.none,
    0.5,
  ),
  StockName.slip => _def(
    name,
    'Slip',
    'll-stock-slip',
    Tooth.fine,
    SheetShadowKind.slip,
    'll-sheet-slip',
    _cut,
    RuleName.none,
    0.7,
  ),
  StockName.indexCard => _def(
    name,
    'Index card',
    'll-stock-index-card',
    Tooth.fine,
    SheetShadowKind.card,
    'll-sheet-card',
    _cut,
    RuleName.indexCard,
    0.5,
  ),
  StockName.graph => _def(
    name,
    'Graph',
    'll-stock-graph',
    Tooth.fine,
    SheetShadowKind.paper,
    '',
    _cut,
    RuleName.graph,
    0.5,
  ),
  StockName.dotGrid => _def(
    name,
    'Dot grid',
    'll-stock-graph',
    Tooth.fine,
    SheetShadowKind.paper,
    '',
    _cut,
    RuleName.dots,
    0.5,
  ),
  StockName.check => _def(
    name,
    'Guest check',
    'll-stock-check',
    Tooth.fine,
    SheetShadowKind.check,
    'll-sheet-check',
    const EdgeSpec(top: EdgeKind.perf),
    RuleName.ledger,
    0.8,
  ),
  StockName.ledger => _def(
    name,
    'Ledger',
    'll-stock-check',
    Tooth.fine,
    SheetShadowKind.check,
    'll-sheet-check',
    _cut,
    RuleName.ledger,
    0.5,
  ),
  StockName.pad => _def(
    name,
    'Order pad',
    'll-stock-pad',
    Tooth.fine,
    SheetShadowKind.pad,
    'll-sheet-pad',
    const EdgeSpec(top: EdgeKind.torn),
    RuleName.pad,
    0.45,
  ),
  StockName.kraft => _def(
    name,
    'Kraft',
    'll-stock-kraft',
    Tooth.kraft,
    SheetShadowKind.slip,
    'll-sheet-slip',
    _cut,
    RuleName.none,
    1,
  ),
  StockName.napkin => _def(
    name,
    'Napkin',
    'll-stock-paper',
    Tooth.cold,
    SheetShadowKind.paper,
    '',
    const EdgeSpec.all(EdgeKind.crimp),
    RuleName.none,
    1.2,
  ),
  StockName.stickyYellow => _sticky(name, 'Sticky yellow'),
  StockName.stickyGreen => _sticky(name, 'Sticky green'),
  StockName.stickyOrange => _sticky(name, 'Sticky orange'),
  StockName.stickyPink => _sticky(name, 'Sticky pink'),
  StockName.stickyBlue => _sticky(name, 'Sticky blue'),
  StockName.photo => _def(
    name,
    'Photo',
    'll-stock-photo',
    Tooth.fine,
    SheetShadowKind.card,
    'll-sheet-card',
    _cut,
    RuleName.window,
    1.5,
  ),
  StockName.parchment => _def(
    name,
    'Parchment',
    '',
    Tooth.cold,
    SheetShadowKind.paper,
    '',
    const EdgeSpec.all(EdgeKind.deckle),
    RuleName.none,
    0.6,
    base: 'paper',
    tint: ('kraft', 0.34),
  ),
  StockName.receipt => _def(
    name,
    'Receipt',
    'll-stock-photo',
    Tooth.none,
    SheetShadowKind.slip,
    'll-sheet-slip',
    const EdgeSpec(top: EdgeKind.zig, bottom: EdgeKind.zig),
    RuleName.none,
    0.9,
  ),
};

final List<StockDef> _all = [for (final s in StockName.values) _stock(s)];

/// Every stock, in upstream order.
///
/// Mirrors `STOCKS` in `src/lib/ink/paper/stocks.ts`.
final Map<StockName, StockDef> stocks = {for (final s in _all) s.name: s};

/// Every stock name (`STOCK_NAMES`).
const List<StockName> stockNames = StockName.values;

/// The stock [name], falling back to `paper`.
///
/// Mirrors `stockOf` in `src/lib/ink/paper/stocks.ts`.
StockDef stockOf(StockName? name) => _all[(name ?? StockName.paper).index];

/// The texture tiles of each tooth, back to front.
///
/// Mirrors `TOOTH_TILES` in `src/lib/ink/paper/stocks.ts`.
const Map<Tooth, List<PaperTileName>> toothTiles = {
  Tooth.cold: [PaperTileName.fibre, PaperTileName.relief, PaperTileName.cloud],
  Tooth.fine: [PaperTileName.fibre, PaperTileName.slip, PaperTileName.cloud],
  Tooth.kraft: [PaperTileName.fibre, PaperTileName.kraft, PaperTileName.cloud],
  Tooth.none: [PaperTileName.cloud],
};

/// The tile sizes of [tooth], as `(w, h)`.
List<(double, double)> toothTileSizes(Tooth tooth) => [
  for (final t in toothTiles[tooth] ?? const <PaperTileName>[])
    (t.cssWidth, t.cssHeight),
];

/// The `box-shadow` of stock [name] raised by [lift].
///
/// Mirrors `stockShadow` in `src/lib/ink/paper/stocks.ts`.
String stockShadow(StockName? name, [double lift = 1]) =>
    sheetShadow(stockOf(name).shadow, lift);
