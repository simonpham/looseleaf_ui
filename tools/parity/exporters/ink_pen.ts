// Pen table and stroke()/dot() output per pen family, for packages/looseleaf_ink/test/pen_test.dart.
import { makeRng } from '@/lib/ink/rng'
import { PENS } from '@/lib/ink/pens'
import { dot, stroke } from '@/lib/ink/pen'
import { ellipsePoly } from '@/lib/ink/geom'
import type { PenName, Pt, StrokeOpts, StrokeResult } from '@/lib/ink/types'
import { writeFixture } from '../write'

const presses: Record<string, (t: number) => number> = {
  taper: (t) => 1 - 0.5 * t,
  swell: (t) => 0.6 + Math.sin(Math.PI * t) * 0.6,
}

type Opts = Omit<StrokeOpts, 'press'> & { press?: keyof typeof presses }

const curve: Pt[] = [[4, 40], [40, 10], [90, 34], [140, 6], [190, 44], [240, 20], [300, 38]]
const zig: Pt[] = [[0, 0], [12, 30], [24, 0], [36, 30], [48, 0]]
const short: Pt[] = [[2, 2], [14, 6]]
const ring: Pt[] = [...ellipsePoly(60, 40, 50, 30, 18), [110, 41]]
const turns: Pt[] = [[0, 0], [60, 0], [60, 40], [0, 40], [0, 8]]
const POINTS: Record<string, Pt[]> = { curve, zig, short, ring, turns, one: [[5, 5]], none: [], bad: [[NaN, 1], [3, Infinity], [12, 4], [10, 10]], far: [[200000, 3], [200010, 3]] }

const json = (r: StrokeResult) => ({
  kind: r.kind,
  layers: r.layers.map((l) => ({ k: l.k, d: l.d, fill: l.fill, op: l.op, rule: l.rule ?? null })),
  bbox: r.bbox,
  len: r.len,
  start: r.start,
  end: r.end,
})

const strokes: unknown[] = []
const run = (pen: PenName, points: string, seed: string, o: Opts) => {
  const opts: StrokeOpts = { ...o, press: o.press ? presses[o.press] : undefined }
  if (opts.press === undefined) delete opts.press
  strokes.push({ pen, points, seed, o, out: json(stroke(POINTS[points], pen, makeRng(seed), opts)) })
}

const families: PenName[] = ['ink', 'ink.fine', 'ink.brush', 'blue', 'focus.fine', 'pencil', 'pencil.fine', 'pencil.brush', 'red', 'bluepencil.brush', 'terracotta', 'hi', 'm_lemon', 'f_grape']
families.forEach((pen, i) => {
  run(pen, 'curve', `c${i}`, { tier: 'lo' })
  run(pen, 'zig', `z${i}`, { tier: 'hi' })
  run(pen, i % 2 ? 'ring' : 'turns', `r${i}`, { tier: i % 3 ? 'lo' : 'hi' })
})
run('ink', 'curve', 'hi-curve', { tier: 'hi' })
run('ink.brush', 'curve', 'brush-hi', { tier: 'hi', dry: 0.5 })
run('pencil', 'curve', 'pencil-hi', { tier: 'hi' })
run('terracotta', 'curve', 'marker-hi', { tier: 'hi' })
run('ink', 'short', 'short-lo', {})
run('ink', 'short', 'short-hi', { tier: 'hi', end: 'flick', start: 'soft' })
run('ink', 'zig', 'simple', { tier: 'hi', simple: true })
run('pencil', 'zig', 'simple-pencil', { tier: 'hi', simple: true })
run('ink', 'turns', 'poly', { poly: true, round: 6, raw: true, start: 'soft', end: 'soft', speed: 1, dry: 0 })
run('pencil', 'turns', 'ruler', { poly: true, raw: true, start: 'soft', end: 'soft', speed: 1, dry: 0 })
run('ink', 'curve', 'opts', { tier: 'hi', width: 1.4, alpha: 0.7, color: 'tomato', wobble: 0.3, speed: 0.6 })
run('blue', 'curve', 'press', { tier: 'hi', press: 'swell', end: 'pool' })
run('hi', 'curve', 'press-hl', { press: 'taper', end: 'flick' })
run('m_sky', 'zig', 'marker-start', { tier: 'hi', start: 'soft', end: 'flick', width: 0.6 })
run('ink', 'one', 'dot-felt', { tier: 'hi' })
run('pencil', 'one', 'dot-pencil', {})
run('ink', 'none', 'nothing', {})
run('ink.fine', 'bad', 'bad-points', { tier: 'hi' })
run('pencil', 'far', 'far-points', {})

const dots: unknown[] = []
for (const [pen, tier, seed, r, o] of [
  ['ink', 'hi', 'd1', 3, {}],
  ['ink', 'lo', 'd2', 1.2, { width: 1.5, alpha: 0.5 }],
  ['blue.brush', 'hi', 'd3', 4, { color: 'grass' }],
  ['pencil', 'hi', 'd4', 2, {}],
  ['red', 'lo', 'd5', 2, {}],
  ['terracotta', 'hi', 'd6', 5, {}],
  ['hi', 'lo', 'd7', 5, {}],
] as const) {
  dots.push({ pen, tier, seed, r, o, out: json(dot(10, 12, r, pen, makeRng(seed), { ...o, tier })) })
}

writeFixture('packages/looseleaf_ink/test/fixtures/pen.json', {
  pens: Object.entries(PENS).map(([name, spec]) => ({ name, spec })),
  points: POINTS,
  strokes,
  dots,
})
