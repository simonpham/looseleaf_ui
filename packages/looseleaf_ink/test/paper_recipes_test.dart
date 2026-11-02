import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => switch (v) {
  final num x => x.toDouble(),
  _ => null,
};

T _by<T extends Enum>(List<T> values, Object? id, [String Function(T)? key]) =>
    values.firstWhere((v) => (key?.call(v) ?? v.name) == id);

Accent? _accent(Object? v) => switch (v) {
  final String a when Accent.values.any((x) => x.name == a) =>
    Accent.values.byName(a),
  _ => null,
};

StockName _stock(Object? v) => StockName.byId(v as String?) ?? StockName.paper;

EdgeKind _kind(Object? v) => switch (v) {
  final String k => EdgeKind.values.byName(k),
  _ => EdgeKind.cut,
};

EdgeSpec _edge(Object? v) => switch (v) {
  final String kind => EdgeSpec.all(EdgeKind.values.byName(kind)),
  final Map<String, dynamic> m => EdgeSpec(
    top: _kind(m['top']),
    right: _kind(m['right']),
    bottom: _kind(m['bottom']),
    left: _kind(m['left']),
  ),
  _ => const EdgeSpec(),
};

List<LayerName> _layers(Object? v) => [
  for (final n in v as List? ?? const []) LayerName.values.byName(n as String),
];

final class _Entry<P> {
  _Entry(this.recipe, this.decode, this.json);

  final Recipe<P> recipe;
  final P Function(_Json p) decode;
  final Map<String, Object?> Function(P p) json;

  (RawFrame, String) run(_Json c) {
    final params = decode(c['params'] as _Json);
    final knobs = c['knobs'] as _Json;
    final frame = runRecipe(
      recipe,
      RunRequest<P>(
        box: Box(_d(c['w']), _d(c['h'])),
        params: params,
        seed: c['seed'] as String,
        tier: Tier.values.byName(c['tier'] as String),
        density: Density.values.byName(c['density'] as String),
        dir: Dir.values.byName(c['dir'] as String),
        knobs: Knobs(
          wobble: _d(knobs['wobble']),
          misreg: _d(knobs['misreg']),
          bleed: _d(knobs['bleed']),
          width: _d(knobs['width']),
        ),
        lazy: _layers(c['lazy']),
        lazyOnly: c['lazyOnly'] == true,
        pad: _od(c['pad']),
      ),
    );
    return (frame, stableStringify(json(params)));
  }
}

final Map<String, _Entry<Object?>> _entries = {
  'paper-sheet': _Entry<SheetParams>(
    sheetRecipe,
    (p) => SheetParams(
      stock: _stock(p['stock']),
      edge: _edge(p['edge']),
      chamfer: _od(p['chamfer']),
      shadow: switch (p['shadow']) {
        final String s when s != 'none' => SheetShadowKind.values.byName(s),
        _ => null,
      },
      noShadow: p['shadow'] == 'none',
    ),
    (p) => p.toJson(),
  ),
  'paper-rules-hand': _Entry<HandRulesParams>(
    handRulesRecipe,
    (p) => HandRulesParams(
      paper: switch (p['paper']) {
        final String paper => HandRulesPaper.values.byName(paper),
        _ => null,
      },
    ),
    (p) => p.toJson(),
  ),
  'paper-set-title-mark': _Entry<TitleMarkParams>(
    titleMarkRecipe,
    (p) => TitleMarkParams(
      kind: TitleMark.values.byName(p['kind'] as String),
      tone: switch (p['tone']) {
        final String t => TitleMarkTone.values.byName(t),
        _ => null,
      },
    ),
    (p) => p.toJson(),
  ),
  'page-decor': _Entry<PageParams>(
    pageRecipe,
    (p) => PageParams(
      holes: PageHoles.values.byName(p['holes'] as String),
      reinforce: p['reinforce'] as bool,
      stain: p['stain'] as bool,
    ),
    (p) => p.toJson(),
  ),
  'notebook-decor': _Entry<NotebookParams>(
    notebookRecipe,
    (p) => NotebookParams(
      binding: NotebookBinding.values.byName(p['binding'] as String),
      side: NotebookSide.values.byName(p['side'] as String),
      pages: p['pages'] as int,
      tone: _accent(p['tone']),
      curl: p['curl'] as bool?,
    ),
    (p) => p.toJson(),
  ),
  'notebook-cover': _Entry<NotebookCoverParams>(
    notebookCoverRecipe,
    (p) =>
        NotebookCoverParams(tone: _accent(p['tone']), band: p['band'] as bool),
    (p) => p.toJson(),
  ),
  'napkin-decor': _Entry<NapkinParams>(
    napkinRecipe,
    (p) => NapkinParams(
      fold: NapkinFold.values.byName(p['fold'] as String),
      stain: p['stain'] as bool,
    ),
    (p) => p.toJson(),
  ),
  'index-card-decor': _Entry<IndexCardParams>(
    indexCardRecipe,
    (p) => IndexCardParams(
      hole: p['hole'] as bool,
      flag: _accent(p['flag']),
      stack: p['stack'] as int,
    ),
    (p) => p.toJson(),
  ),
  'envelope-back': _Entry<EnvelopeBackParams>(
    envelopeBackRecipe,
    (p) => EnvelopeBackParams(stock: _stock(p['stock'])),
    (p) => p.toJson(),
  ),
  'envelope-front': _Entry<EnvelopeFrontParams>(
    envelopeFrontRecipe,
    (p) => EnvelopeFrontParams(
      stock: _stock(p['stock']),
      stamp: _accent(p['stamp']),
      postmark: p['postmark'] as bool,
      airmail: p['airmail'] as bool,
    ),
    (p) => p.toJson(),
  ),
  'folder-tab': _Entry<FolderTabParams>(
    folderTabRecipe,
    (p) => FolderTabParams(
      stock: _stock(p['stock']),
      disabled: p['disabled'] as bool,
    ),
    (p) => p.toJson(),
  ),
  'folder-body': _Entry<FolderBodyParams>(
    folderBodyRecipe,
    (p) => FolderBodyParams(crease: p['crease'] as bool),
    (p) => p.toJson(),
  ),
  'clipboard-board': _Entry<ClipboardBoardParams>(
    clipboardBoardRecipe,
    (p) => ClipboardBoardParams(tone: _accent(p['tone'])),
    (p) => p.toJson(),
  ),
  'bookmark-ribbon': _Entry<BookmarkParams>(
    bookmarkRecipe,
    (p) => BookmarkParams(
      tone: Accent.values.byName(p['tone'] as String),
      mode: _by(BookmarkMode.values, p['mode'], (m) => m.id),
      disabled: p['disabled'] as bool,
    ),
    (p) => p.toJson(),
  ),
  'label-tag-sheet': _Entry<LabelTagParams>(
    labelTagRecipe,
    (p) => LabelTagParams(
      stock: _stock(p['stock']),
      shape: TagShape.values.byName(p['shape'] as String),
      string: _d(p['string']),
      twine: _accent(p['twine']),
      eyelet: TagEyelet.values.byName(p['eyelet'] as String),
    ),
    (p) => p.toJson(),
  ),
  'ticket-sheet': _Entry<TicketParams>(
    ticketRecipe,
    (p) => TicketParams(
      stock: _stock(p['stock']),
      stub: TicketStubSide.values.byName(p['stub'] as String),
      stubWidth: _d(p['stubWidth']),
      punched: p['punched'] as bool,
    ),
    (p) => p.toJson(),
  ),
  'separator': _Entry<SeparatorParams>(
    separatorRecipe,
    (p) => SeparatorParams(
      variant: SeparatorVariant.values.byName(p['variant'] as String),
      orientation: SeparatorOrientation.values.byName(
        p['orientation'] as String,
      ),
    ),
    (p) => p.toJson(),
  ),
  'marquee-band': _Entry<MarqueeBandParams>(
    marqueeBandRecipe,
    (p) => MarqueeBandParams(
      kind: switch (p['kind']) {
        final String k => _by(TapeKind.values, k, (t) => t.id),
        _ => null,
      },
      color: _accent(p['color']),
    ),
    (p) => p.toJson(),
  ),
  'marquee-control': _Entry<MarqueeControlParams>(
    marqueeControlRecipe,
    (p) => MarqueeControlParams(paused: p['paused'] as bool),
    (p) => p.toJson(),
  ),
  'sticky-note-decor': _Entry<NoParams>(
    stickyNoteRecipe,
    (_) => const NoParams(),
    (p) => p.toJson(),
  ),
  'signature-baseline': _Entry<SignatureBaselineParams>(
    signatureBaselineRecipe,
    (p) => SignatureBaselineParams(invalid: p['invalid'] as bool?),
    (p) => p.toJson(),
  ),
};

void main() {
  final fixture =
      jsonDecode(
            File('test/fixtures/paper_recipes.json').readAsStringSync(),
          )
          as _Json;
  for (final c in (fixture['frames'] as List).cast<_Json>()) {
    test(c['name'], () {
      final entry = _entries[c['recipe']];
      if (entry == null) fail('no entry for ${c['recipe']}');
      final (frame, key) = entry.run(c);
      final out = c['out'] as _Json;
      expect(key, c['key']);
      expect(frame.layers.map((l) => l.name), out['layers']);
      expect(frame.lazyLayers.map((l) => l.name), out['lazyLayers']);
      expect([frame.pad, frame.w, frame.h], [out['pad'], out['w'], out['h']]);
      final parts = out['parts'] as _Json;
      expect(frame.parts.keys.map((k) => k.name), parts.keys);
      for (final MapEntry(:key, :value) in parts.entries) {
        expect(frame.parts[LayerName.values.byName(key)], value, reason: key);
      }
    });
  }
}
