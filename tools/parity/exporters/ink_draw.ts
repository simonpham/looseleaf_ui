// Shapes and fills: the polylines each *Lines function makes, and the Ink markup of every shape and fill
// function, for packages/looseleaf_ink/test/shapes_test.dart and fills_test.dart.
import { makeRng } from '@/lib/ink/rng'
import { Ink } from '@/lib/ink/builder'
import { roundRectPoly, ellipsePoly } from '@/lib/ink/geom'
import * as S from '@/lib/ink/shapes'
import * as F from '@/lib/ink/fills'
import type { Line, Pt, Tier } from '@/lib/ink/types'
import { writeFixture } from '../write'

type Args = unknown[]
const lineJson = (l: Line) => ({ pts: l.pts, o: l.o ?? null, pen: l.pen ?? null })

// ---- *Lines functions ----
const linesCases: unknown[] = []
const L = (fn: string, seed: string, args: Args, o: Record<string, unknown>, lines: Line[]) =>
  linesCases.push({ fn, seed, args, o, out: lines.map(lineJson) })
const r = (seed: string) => makeRng(seed)

L('chain', 'ch1', [[[0, 0], [80, 0], [80, 30], [0, 30], [0, 2]], [0.4, -0.3, 0.2, 0.1], 3.5], {}, [{ pts: S.chain([[0, 0], [80, 0], [80, 30], [0, 30], [0, 2]], [0.4, -0.3, 0.2, 0.1], 3.5, r('ch1')) }])
L('chain', 'ch2', [[[5, 40], [50, 40], [50, 6]], [0.25], 0.2], {}, [{ pts: S.chain([[5, 40], [50, 40], [50, 6]], [0.25], 0.2, r('ch2')) }])
L('lineLines', '', [1, 2, 90, 7], {}, S.lineLines(1, 2, 90, 7))
for (const [seed, w, o] of [['sq1', 120, {}], ['sq2', 420, { h: 20, amp: 1.3 }], ['sq3', 60, { wl: 0.7 }]] as const) L('squiggleLines', seed, [4, 20, w], o, S.squiggleLines(r(seed), 4, 20, w, o))
for (const kind of ['single', 'double', 'wavy', undefined] as const) L('underlineLines', `ul-${kind}`, [3, 30, 140], kind ? { kind } : {}, S.underlineLines(r(`ul-${kind}`), 3, 30, 140, kind ? { kind } : {}))
for (const [seed, o] of [['st1', {}], ['st2', { double: true }]] as const) L('strikeLines', seed, [10, 12, 90], o, S.strikeLines(r(seed), 10, 12, 90, o))
for (const [seed, w, h, o] of [['bx1', 120, 36, {}], ['bx2', 40, 40, { corner: 8, loose: 0.6, wobble: 2 }], ['bx3', 400, 24, { corner: 0 }]] as const) L('boxLines', seed, [0, 0, w, h], o, S.boxLines(r(seed), 0, 0, w, h, o))
for (const [seed, o] of [['lp1', {}], ['lp2', { clean: true }], ['lp3', { turns: 1.4, a0: 0.3, drift: 0.02, breathe: 0.1, loose: 2 }], ['lp4', { clean: true, a0: -1 }]] as const) L('loopLines', seed, [50, 30, 40, 22], o, S.loopLines(r(seed), 50, 30, 40, 22, o))
for (const [seed, o] of [['ar1', {}], ['ar2', { head: 'two', curve: 0.2 }], ['ar3', { head: 'open', headLen: 9 }], ['ar4', { head: 'solid', curl: true }], ['ar5', { head: 'none' }], ['ar6', { curl: true, head: 'v' }]] as const) L('arrowLines', seed, [10, 10, 130, 60], o, S.arrowLines(r(seed), 10, 10, 130, 60, o))
L('checkLines', 'ck', [2, 3, 20], {}, S.checkLines(r('ck'), 2, 3, 20))
L('crossLines', 'cr', [2, 3, 16], {}, S.crossLines(r('cr'), 2, 3, 16))
L('asteriskLines', 'as', [20, 20, 14], {}, S.asteriskLines(r('as'), 20, 20, 14))
for (const [seed, o] of [['spi1', {}], ['spi2', { turns: 3, steps: 40, shrink: 0.5 }]] as const) L('spiralLines', seed, [30, 30, 20], o, S.spiralLines(r(seed), 30, 30, 20, o))
L('starLines', 'sta', [30, 30, 18], {}, S.starLines(r('sta'), 30, 30, 18))
for (const [seed, count] of [['ta1', 3], ['ta2', 12]] as const) {
  const t = S.tallyLines(r(seed), 4, 4, count, 20)
  linesCases.push({ fn: 'tallyLines', seed, args: [4, 4, count, 20], o: {}, out: t.lines.map(lineJson), width: t.width })
}
for (const [seed, o] of [['br1', {}], ['br2', { kind: 'curly', dir: -1 }], ['br3', { kind: 'round' }], ['br4', { kind: 'square', dir: -1 }]] as const) L('bracketLines', seed, [10, 4, 60], o, S.bracketLines(r(seed), 10, 4, 60, o))
for (const [seed, w, h, o] of [['cl1', 120, 60, {}], ['cl2', 300, 90, { bulge: 5 }], ['cl3', 20, 20, {}]] as const) L('cloudLines', seed, [100, 60, w, h], o, S.cloudLines(r(seed), 100, 60, w, h, o))
L('scribbleLines', 'scr', [4, 4, 80, 16], {}, S.scribbleLines(r('scr'), 4, 4, 80, 16))
for (const [seed, o] of [['bu1', {}], ['bu2', { rays: 7 }]] as const) L('burstLines', seed, [30, 30, 20], o, S.burstLines(r(seed), 30, 30, 20, o))
for (const [seed, o] of [['fr1', {}], ['fr2', { shape: 'ellipse', gap: 3 }], ['fr3', { ticks: true, r: 8 }], ['fr4', { shape: 'ellipse', ticks: true }]] as const) L('focusRingLines', seed, [0, 0, 120, 36], o, S.focusRingLines(r(seed), 0, 0, 120, 36, o))
for (const [seed, w, h, o] of [['db1', 120, 36, {}], ['db2', 40, 40, { r: 0, dash: 4, gap: 3 }], ['db3', 200, 30, { r: 12 }]] as const) L('dashedBoxLines', seed, [0, 0, w, h], o, S.dashedBoxLines(r(seed), 0, 0, w, h, o))

// ---- markup of every drawing call ----
type Draw = { name: string; seed: string; tier: Tier; w: number; h: number; call: string; args: Args; o: Record<string, unknown> }
const markup = (cases: Draw[], fn: (ink: Ink, c: Draw) => void) =>
  cases.map((c) => {
    const ink = new Ink(c.seed, { tier: c.tier })
    fn(ink, c)
    const res = ink.toSvg({ w: c.w, h: c.h })
    return { ...c, out: { svg: res.svg, pad: res.pad, bbox: res.bbox, layers: res.layers } }
  })

const D = (call: string, args: Args, o: Record<string, unknown> = {}, tier: Tier = 'lo', w = 140, h = 60): Draw => ({ name: `${call} ${tier} ${JSON.stringify(o)}`, seed: `${call}-${tier}-${JSON.stringify(o)}`, tier, w, h, call, args, o })

const shapeDraws: Draw[] = [
  D('line', [2, 2, 120, 10]), D('line', [2, 2, 120, 10], { pen: 'ink' }, 'hi'),
  D('squiggle', [4, 30, 130]), D('squiggle', [4, 30, 130], { pen: 'blue', h: 18 }, 'hi'),
  D('underline', [4, 40, 120]), D('underline', [4, 40, 120], { kind: 'double', pen: 'pencil.fine', opts: { alpha: 0.6 } }, 'hi'), D('underline', [4, 40, 120], { kind: 'wavy' }),
  D('strike', [4, 20, 100]), D('strike', [4, 20, 100], { double: true }, 'hi'),
  D('box', [0, 0, 140, 60]), D('box', [0, 0, 140, 60], { pen: 'pencil.fine', corner: 4, opts: { alpha: 0.42 } }, 'hi'), D('box', [1.2, 1.2, 100, 30], { pen: 'red.fine', corner: 3, loose: 0.6, opts: { alpha: 0.7, simple: true } }),
  D('loop', [70, 30, 60, 24]), D('loop', [70, 30, 60, 24], { clean: true, pen: 'redfelt', opts: { alpha: 0.6, width: 0.85 } }, 'hi'),
  D('arrow', [10, 10, 130, 50]), D('arrow', [10, 10, 130, 50], { head: 'solid', curl: true }, 'hi'), D('arrow', [10, 50, 130, 10], { head: 'two', pen: 'pencil' }),
  D('check', [10, 10, 30]), D('check', [10, 10, 30], {}, 'hi'),
  D('cross', [10, 10, 30]), D('asterisk', [30, 30, 20], {}, 'hi'), D('spiral', [40, 30, 24], { turns: 3 }), D('star', [40, 30, 24], {}, 'hi'),
  D('tally', [4, 4, 7, 24]), D('bracket', [10, 4, 50], { kind: 'curly' }), D('bracket', [10, 4, 50], {}, 'hi'),
  D('cloud', [70, 30, 120, 50]), D('scribble', [4, 4, 100, 30], {}, 'hi'), D('burst', [40, 30, 24], { rays: 8 }),
  D('focusRing', [0, 0, 140, 60]), D('focusRing', [0, 0, 140, 60], { r: 8, ticks: true }, 'hi'), D('focusRing', [0, 0, 60, 60], { shape: 'ellipse', ticks: true }),
  D('dashedBox', [0, 0, 140, 60]), D('dashedBox', [0, 0, 140, 60], { r: 4, pen: 'pencil', opts: { color: 'pencil-mark' } }, 'hi'), D('dashedBox', [0, 0, 100, 30], { pen: 'ink.fine', opts: { width: 1.3, alpha: 0.5 } }),
]

const body = roundRectPoly(0.5, 0.5, 139, 59, 4)
const tri: Pt[] = [[10, 10], [130, 20], [40, 55]]
const disc = ellipsePoly(70, 30, 50, 24, 30)
const POLYS: Record<string, Pt[]> = { body, tri, disc }

const fillDraws: Draw[] = [
  D('solidFill', ['body', 'marker']), D('solidFill', ['tri', 'hi'], { alpha: 0.5, inset: 2, rough: 0.4, material: 'wash' }, 'hi'),
  D('flatFill', ['tri', 'red']), D('flatFill', ['disc', 'sky', 0.3, 'hl']),
  D('bandFill', ['body', 'marker'], { passes: 2, alpha: 0.84 }), D('bandFill', ['disc', 'red'], { passes: 1, alpha: 0.97, material: 'felt' }, 'hi'), D('bandFill', ['body', 'hi'], {}),
  D('clipFill', ['body', 'grass']), D('clipFill', ['tri', 'grass'], { alpha: 0.5, rough: 1 }, 'hi'),
  D('blobFill', ['disc', 'marker'], { alpha: 0.9 }), D('blobFill', ['body', 'hi'], { alpha: 0.85, rough: 0.5 }, 'hi'),
  D('wash', ['body', 'hi'], { alpha: 0.5 }), D('wash', ['body', 'paper-shade'], { alpha: 0.9, material: 'wash' }, 'hi'), D('wash', ['tri', 'marker'], { inset: 2, shift: 1, wobble: 2 }),
  D('polyFill', ['tri', 'teal']), D('sweepFill', [4, 4, 100, 30, 'lemon'], { alpha: 0.6 }),
  D('hatch', ['body'], {}), D('hatch', ['disc'], { cross: true, gap: 3, pen: 'ink.fine', alpha: 0.6 }, 'hi'), D('hatch', ['rect:10,10,100,40'], { tones: 3, cross: 60, angle: 30, skip: 0.2, width: 0.8 }),
  D('edgeBand', [0, 0, 140, 60, 'b']), D('edgeBand', [0, 0, 140, 60, 'l'], { thick: 6, gap: 2, inset: 4, pen: 'pencil', alpha: 0.6, width: 1 }, 'hi'), D('edgeBand', [0, 0, 140, 60, 't']), D('edgeBand', [0, 0, 140, 60, 'r']),
  D('stipple', [4, 4, 100, 40, 30]), D('stipple', [4, 4, 100, 40, 12], { pen: 'pencil', alpha: 0.5 }, 'hi'),
  D('contourArcs', [70, 30, 50, 24]), D('contourArcs', [70, 30, 50, 24], { n: 6, dir: -1, alpha: 0.5 }, 'hi'),
  D('highlight', [6, 10, 120, 30]), D('highlight', [6, 10, 120, 30], { k: 1, pen: 'm_lemon' }, 'hi'), D('highlight', [6, 10, 120, 30], { opts: { end: 'soft', width: 0.8 } }),
]

const polyArg = (v: unknown): Pt[] => {
  const s = String(v)
  if (s.startsWith('rect:')) {
    const [x, y, w, h] = s.slice(5).split(',').map(Number)
    return [[x, y], [x + w, y], [x + w, y + h], [x, y + h]]
  }
  return POLYS[s]
}

const shapes = markup(shapeDraws, (ink, c) => {
  const fn = (S as unknown as Record<string, (...a: unknown[]) => void>)[c.call]
  fn(ink, ...c.args, c.o)
})

const fills = markup(fillDraws, (ink, c) => {
  const a = c.args
  switch (c.call) {
    case 'flatFill': return F.flatFill(ink, polyArg(a[0]), a[1] as never, a[2] as number | undefined, a[3] as never)
    case 'sweepFill': F.sweepFill(ink, a[0] as number, a[1] as number, a[2] as number, a[3] as number, a[4] as never, c.o); return
    case 'hatch': return F.hatch(ink, polyArg(a[0]), c.o)
    case 'edgeBand': return F.edgeBand(ink, a[0] as number, a[1] as number, a[2] as number, a[3] as number, a[4] as never, c.o)
    case 'stipple': return F.stipple(ink, a[0] as number, a[1] as number, a[2] as number, a[3] as number, a[4] as number, c.o)
    case 'contourArcs': return F.contourArcs(ink, a[0] as number, a[1] as number, a[2] as number, a[3] as number, c.o)
    case 'highlight': return F.highlight(ink, a[0] as number, a[1] as number, a[2] as number, a[3] as number, c.o)
    default: {
      const fn = (F as unknown as Record<string, (...x: unknown[]) => unknown>)[c.call]
      const off = fn(ink, polyArg(a[0]), a[1], c.o)
      ;(c as Draw & { offset?: unknown }).offset = off
    }
  }
})

const misc = {
  misreg: [['m1', 3, {}], ['m2', 1.5, { bias: -1, tilt: 2, grow: 4 }]].map(([seed, amt, o]) => ({ seed, amt, o, out: F.misreg(body, makeRng(seed as string), amt as number, o as never) })),
  defaultMis: [body, tri, disc].map((p) => F.defaultMis(p)),
  rough: [['ro1', 0.8, 4], ['ro2', 2, 9]].map(([seed, amt, step]) => ({ seed, amt, step, out: F.rough(tri, makeRng(seed as string), amt as number, step as number) })),
  bandPoly: [['bp1', 9, 0.34, 72], ['bp2', 20, 0.8, 5]].map(([seed, width, chisel, maxPts]) => ({ seed, width, chisel, maxPts, out: F.bandPoly([3, 4], [180, 30], width as number, makeRng(seed as string), chisel as number, maxPts as number) })),
}

writeFixture('packages/looseleaf_ink/test/fixtures/shapes.json', { lines: linesCases, draws: shapes })
writeFixture('packages/looseleaf_ink/test/fixtures/fills.json', { polys: POLYS, draws: fills, misc })
