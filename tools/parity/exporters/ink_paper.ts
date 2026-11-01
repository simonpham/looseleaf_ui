// Paper stocks, rules, shadows, edges and faces, for packages/looseleaf_ink/test/paper_test.dart.
import {
  STOCKS, STOCK_NAMES, stockShadow, ruleGeometry, rulesLayer, ruleOffsetFor, sheetShadow, contactShadow, farShadow, dropShadow,
  tiltFor, tiltLimit, tiltVars, tileOffsets, edgeSides, isCutEdge, edgeName, edgeInset, sheetOutline, outlinePath, sideInsets,
  faceMark, shadowMark, splitFaces, hasFace, tilesOf, faceLook, faceClip, translatePath, pathBox, faceSvg, renderFaces,
  type EdgeSpec, type RuleName, type SheetShadowKind, type DropKind, type StockName, type FaceSpec,
} from '@/lib/ink/paper'
import { makeRng } from '@/lib/ink/rng'
import { writeFixture } from '../write'

const stocks = STOCK_NAMES.map((name) => {
  const s = STOCKS[name]
  return {
    name, label: s.label, color: s.color, base: s.base, tint: s.tint ?? null, stockClass: s.stockClass, tooth: s.tooth, toothClass: s.toothClass,
    shadow: s.shadow, shadowClass: s.shadowClass, edge: edgeSides(s.edge), rules: s.rules, tilt: s.tilt, gum: !!s.gum,
    shadows: [1, 1.5, 0.6].map((lift) => stockShadow(name, lift)),
  }
})

const RULES: RuleName[] = ['none', 'ruled', 'ruled-hand', 'index', 'graph', 'dots', 'ledger', 'pad', 'window']
const rules = RULES.flatMap((kind) =>
  [{}, { calm: true }, { first: 30 }, { calm: true, first: 61 }].map((o) => {
    const g = ruleGeometry(kind, o)
    const layer = rulesLayer(kind, o)
    return { kind, o, geo: { ...g, cols: g.cols ?? null, margin: g.margin ?? null, major: g.major ?? null }, layer: layer ? { pitch: layer.pitch, style: layer.style } : null }
  }),
)
const offsets = [[28, 17], [24, 17], [30, 15], [22, 15], [17.3, 12.9]].map(([p, fs]) => ({ p, fs, out: ruleOffsetFor(p, fs) }))

const KINDS: SheetShadowKind[] = ['hair', 'loose', 'lift', 'slip', 'card', 'pad', 'check', 'paper', 'sticky']
const shadows = KINDS.map((kind) => ({
  kind,
  sheet: [1, 0.5, 1.4, 2.2, 0].map((lift) => sheetShadow(kind, lift)),
  contact: contactShadow(kind),
  far: farShadow(kind),
  farAll: farShadow(kind, true),
}))
const DROPS: DropKind[] = ['sheet', 'sticker', 'tape', 'prop']
const drops = DROPS.map((kind) => ({ kind, out: [1, 0.5, 1.7].map((lift) => dropShadow(kind, lift)) }))
const tilts = (['a', 'paper-7', 42, 0, 'zz'] as const).flatMap((seed) => [0.6, 1.6, 2].map((max) => ({ seed, max, out: tiltFor(seed, max) })))
const limits = [[300, 200], [40, 30], [5, 5], [1200, 80], [0.5, 0.2], [10, 3]].flatMap(([w, h]) =>
  [[5, 2], [2, 4], [12, 1]].map(([shift, cap]) => ({ w, h, shift, cap, out: tiltLimit(w, h, shift, cap) })),
)
const tex = (['s1', 7, 'paper:3'] as const).map((seed) => ({ seed, sizes: [[240, 240], [192, 96], [720, 720]], out: tileOffsets(seed, [[240, 240], [192, 96], [720, 720]]) }))
const asin = [-1, -0.99, -0.6, -0.5, -0.2, 0, 1e-9, 0.01, 0.0333, 0.25, 0.4999, 0.5, 0.7, 0.975, 0.98, 0.9999, 1].map((x) => ({ x, out: Math.asin(x) }))

const SPECS: EdgeSpec[] = ['cut', 'torn', 'deckle', 'crimp', 'zig', 'perf', 'scallop', { top: 'perf' }, { top: 'torn', bottom: 'zig' }, { left: 'scallop', right: 'deckle' }]
const edgeInfo = SPECS.map((edge) => ({ edge, sides: edgeSides(edge), cut: isCutEdge(edge), name: edgeName(edge), inset: edgeInset(edge) }))
const r2 = (pts: [number, number][]) => pts
const outlines = SPECS.flatMap((edge, k) =>
  [
    { w: 140, h: 90, o: {} },
    { w: 64, h: 40, o: { amp: 0.6 } },
    { w: 110, h: 70, o: { chamfer: 18 } },
  ].map(({ w, h, o }) => {
    const seed = `edge-${k}-${w}`
    const out = sheetOutline(makeRng(seed), w, h, edge, o)
    return {
      seed, w, h, edge, o,
      pts: r2(out.pts), rim: r2(out.rim), crisp: out.crisp, reach: out.reach, fibrous: out.fibrous, sides: out.sides,
      bodyLo: outlinePath(out, 'body'), bodyHi: outlinePath(out, 'body', 'hi'), rimLo: outlinePath(out, 'rim'),
      insets: sideInsets(out, w, h, o.chamfer ?? 0),
    }
  }),
)

const faceSpecs: FaceSpec[] = [
  { d: 'M0 0H100V60H0Z', stock: 'paper', seed: 12345 },
  { d: 'M2.5 3L98.1 2.2L97 58.4L1 59Z', stock: 'parchment', seed: 4000000000, veil: false, cast: { kind: 'paper', inset: [1, 1.5, 2, 0.4] } },
  { d: 'M0 0H50V50H0ZM10 10V40H40V10Z', stock: 'sticky-yellow', seed: 77, evenodd: true },
  { d: 'M0 0H50V50H0Z', stock: 'sticky-pink', seed: 78, veil: false, evenodd: true, cast: { kind: 'sticky', inset: [1, 1, 1, 1] } },
  { d: 'M5 5h40v20h-40z', stock: 'receipt', seed: 9 },
  { d: 'M0 0H80V40H0Z', stock: 'kraft', seed: 31, cast: { kind: 'slip', inset: [0, 0, 0, 0], radius: [4, 4, 4, 4] } },
  { d: 'M0 0--1 2', stock: 'graph', seed: 1 },
]
const marks = faceSpecs.map((spec) => ({ spec, mark: faceMark(spec) }))
const shadowMarks = [shadowMark('lift', [11, 11, 11, 11]), shadowMark('lift', [3, 9, 9, 3], [0.5, 1, 1, 0])]
const mixed = `<g a="1"/>${marks[0].mark}<path d="M0 0"/>${shadowMarks[0]}${marks[1].mark}<g/>`
const split = { markup: mixed, has: hasFace(mixed), pieces: splitFaces(mixed), plainHas: hasFace('<g/>') }
const looks = STOCK_NAMES.flatMap((stock) => [true, false].map((veil) => ({ stock, seed: `look-${stock}`, veil, out: faceLook(stock, `look-${stock}`, veil) })))
const tiles = [[...STOCK_NAMES], ['paper', 'kraft'], ['receipt'], ['graph', 'paper', 'slip']].map((s) => ({ stocks: s, out: tilesOf(s as StockName[]) }))
const PATHS = [
  'M0 0H100V60H0Z', 'M 10.5,20 L30 40', 'M10 20l5 5h3v-2z', 'M1 2C3 4 5 6 7 8S9 10 11 12Q1 1 2 2T5 5', 'M0 0A10 10 0 0 1 20 0A5 8 30 1 0 30 10z',
  'm5 5l10 0l0 10z', 'M.5 .5L-3.25 1e1', 'M10 10H20M30 30V5', 'M0 0L5', 'M10 10 20 20 30 5', 'M3 4a5 5 0 1 0 10 0a5 5 0 1 0 -10 0z', 'X1 2', '',
  'M0 0A0 4 0 0 1 9 9', 'M5 5A3 3 0 0 0 5 5L6 6', 'M0 0A1 1 0 0 1 50 0',
]
const paths = PATHS.map((d) => ({ d, moved: [[0, 0], [3, -2.5], [0.333, 1.666]].map(([dx, dy]) => translatePath(d, dx, dy)), box: pathBox(d) }))
const clips = faceSpecs.map((spec) => [faceClip(spec), faceClip(spec, 4, 4), faceClip(spec, 0, 2.5)])
const svgs = faceSpecs.flatMap((spec) => [faceSvg(spec), faceSvg(spec, { tiles: true }), faceSvg(spec, { tiles: true, id: 'x-' })])
const rendered = [renderFaces(mixed), renderFaces(mixed, { tiles: true, id: 'r' }), renderFaces('<g/>')]

writeFixture('packages/looseleaf_ink/test/fixtures/paper.json', {
  stocks, rules, offsets, shadows, drops, tilts, limits, tex, tiltVars: tiltVars(1.25), asin,
  edgeInfo, outlines, marks, shadowMarks, split, looks, tiles, paths, clips, svgs, rendered,
})
