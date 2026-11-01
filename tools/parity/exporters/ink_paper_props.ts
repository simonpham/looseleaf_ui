// Paper props (tape, fasteners, stitches, bands, rings, curls, rulers), for packages/looseleaf_ink/test/paper_props_test.dart.
import { tape, clip, pin, staple, binderClip, stitches, rubberBand, coffeeRing, stickyCurl, ruler, curlMarkup, TAPE_KINDS } from '@/lib/ink/paper'
import type { InkResult } from '@/lib/ink/builder'
import { makeRng } from '@/lib/ink/rng'
import { writeFixture } from '../write'

const res = (r: InkResult) => ({ svg: r.svg, w: r.w, h: r.h, pad: r.pad })
const cases: Array<{ fn: string; seed: string; args: unknown[]; o: Record<string, unknown>; out: unknown }> = []
const add = (fn: string, seed: string, args: unknown[], o: Record<string, unknown>, out: InkResult) => cases.push({ fn, seed, args, o, out: res(out) })

for (const kind of TAPE_KINDS) {
  add('tape', `tape-${kind}`, [], { kind }, tape(`tape-${kind}`, { kind }))
  add('tape', `tape-${kind}-b`, [], { kind, length: 130, height: 28, tier: 'hi' }, tape(`tape-${kind}-b`, { kind, length: 130, height: 28, tier: 'hi' }))
}
for (const ends of ['saw', 'torn', 'straight', 'scissor'] as const) add('tape', `ends-${ends}`, [], { ends, color: 'teal' }, tape(`ends-${ends}`, { ends, color: 'teal' }))
for (const seed of ['c1', 'c2']) add('clip', seed, [], {}, clip(seed))
add('clip', 'c3', [], { height: 90, tone: 'grape', angle: -3, calm: true }, clip('c3', { height: 90, tone: 'grape', angle: -3, calm: true }))
add('clip', 'c4', [], { tone: 'steel', angle: 0 }, clip('c4', { tone: 'steel', angle: 0 }))
for (const seed of ['p1', 'p2']) add('pin', seed, [], {}, pin(seed))
add('pin', 'p3', [], { size: 40, color: 'sky' }, pin('p3', { size: 40, color: 'sky' }))
add('staple', 's1', [], {}, staple('s1'))
add('staple', 's2', [], { length: 30, double: true }, staple('s2', { length: 30, double: true }))
add('binderClip', 'b1', [], {}, binderClip('b1'))
add('binderClip', 'b2', [], { width: 70, tier: 'hi' }, binderClip('b2', { width: 70, tier: 'hi' }))
add('stitches', 'st1', [160, 100], {}, stitches('st1', 160, 100))
add('stitches', 'st2', [90, 60], { inset: 5, radius: 20, color: 'red', stitch: 5, gap: 3 }, stitches('st2', 90, 60, { inset: 5, radius: 20, color: 'red', stitch: 5, gap: 3 }))
add('rubberBand', 'rb1', [40, 120], {}, rubberBand('rb1', 40, 120))
add('rubberBand', 'rb2', [12, 60], { color: 'grape' }, rubberBand('rb2', 12, 60, { color: 'grape' }))
add('coffeeRing', 'cr1', [], {}, coffeeRing('cr1'))
add('coffeeRing', 'cr2', [], { radius: 30 }, coffeeRing('cr2', { radius: 30 }))
add('stickyCurl', 'cu1', [24], {}, stickyCurl('cu1', 24))
add('stickyCurl', 'cu2', [40], { color: 'sticky-blue' }, stickyCurl('cu2', 40, { color: 'sticky-blue' }))
add('ruler', 'ru1', [200], {}, ruler('ru1', 200))
add('ruler', 'ru2', [77], { height: 22 }, ruler('ru2', 77, { height: 22 }))

const curl = { seed: 'cm', id: 'cid', c: 30, out: curlMarkup(makeRng('cm'), 'cid', 30, 'sticky-green') }

writeFixture('packages/looseleaf_ink/test/fixtures/paper_props.json', { cases, curl })
