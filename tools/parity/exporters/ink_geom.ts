// Geometry helpers, for packages/looseleaf_ink/test/geom_test.dart. Each case is { fn, args, out }.
import { makeRng } from '@/lib/ink/rng'
import {
  PathWriter, TIERS, area, bboxOf, centroid, densify, densifyClosed, ellipsePoly, fillet, inside, offsetPoly, pathLength, pillPoly, polyPath,
  resample, roundRectPoly, rounded, scanSpans, seg, simplePath, simplifyClosed, smoothClosed, spline, wobblePoly, xform,
} from '@/lib/ink/geom'
import type { Pt } from '@/lib/ink/types'
import { writeFixture } from '../write'

const zig: Pt[] = [[0, 0], [10, 3], [22, -4], [30, 12], [41, 9], [44, 30]]
const tri: Pt[] = [[2, 2], [60, 8], [20, 40]]
const blob: Pt[] = ellipsePoly(50, 30, 40, 22, 40).map(([x, y], i) => [x + Math.sin(i * 1.7) * 3, y + Math.cos(i * 2.3) * 2] as Pt)
const rect = roundRectPoly(0.5, 0.5, 119, 35, 4)
const big = roundRectPoly(10, 10, 300, 120, 18, 9)

const cases: Array<{ fn: string; args: unknown[]; out: unknown }> = []
const add = (fn: string, args: unknown[], out: unknown) => cases.push({ fn, args, out })

for (const [x1, y1, x2, y2, bow, cnt] of [[0, 0, 100, 0, 0, 8], [3, 4, -20, 50, 2.5, 5], [5, 5, 5, 5, 1, 3], [0, 0, 33.3, 12.1, -0.7, 12]]) {
  add('seg', [x1, y1, x2, y2, bow, cnt], seg(x1, y1, x2, y2, bow, cnt))
}
for (const step of [1.5, 3.2, 0.7]) add('densify', [zig, step], densify(zig, step))
for (const step of [1.5, 2.7]) add('spline', [zig, step], spline(zig, step))
add('spline', [[[0, 0], [5, 5]], 1.5], spline([[0, 0], [5, 5]], 1.5))
add('spline', [tri, 1.8], spline(tri, 1.8))
for (const r of [0, 3, 50]) add('fillet', [zig, r], fillet(zig, r))
for (const [seed, rad, per] of [['r1', 3, 5], ['r2', 12, 3]] as const) add('rounded', [zig, rad, seed, per], rounded(zig, rad, makeRng(seed), per))
add('pathLength', [zig], pathLength(zig))
for (const step of [1.8, 4, 100]) {
  const r = resample(zig, step)
  add('resample', [zig, step], { X: [...r.X], Y: [...r.Y], S: [...r.S], L: r.L })
}
for (const tol of [0.085, 0.16, 0.5, 2]) add('simplifyClosed', [blob, tol], simplifyClosed(blob, tol))
add('simplifyClosed', [tri, 0.5], simplifyClosed(tri, 0.5))
for (const tier of ['hi', 'lo'] as const) {
  add('smoothClosed', [blob, tier], smoothClosed(blob, TIERS[tier]))
  add('smoothClosed', [rect, tier], smoothClosed(rect, TIERS[tier]))
  add('simplePath', [blob, tier], simplePath(blob, TIERS[tier]))
}
for (const q of [10, 20, 100] as const) add('polyPath', [zig, q], polyPath(zig, q))
add('area', [blob], area(blob))
add('area', [tri], area(tri))
add('bboxOf', [blob], bboxOf(blob))
add('centroid', [blob], centroid(blob))
add('centroid', [[[0, 0], [1, 1], [2, 2]]], centroid([[0, 0], [1, 1], [2, 2]]))
for (const [x, y] of [[50, 30], [0, 0], [89, 30], [91, 30], [20, 15]]) add('inside', [blob, x, y], inside(blob, x, y))
add('xform', [tri, { dx: 3, dy: -2, rot: 0.3, sx: 1.2 }], xform(tri, { dx: 3, dy: -2, rot: 0.3, sx: 1.2 }))
add('xform', [tri, { rot: -0.05, sx: 0.9, sy: 1.1, about: [0, 0] }], xform(tri, { rot: -0.05, sx: 0.9, sy: 1.1, about: [0, 0] }))
for (const [x, y, w, h, r, per] of [[0.5, 0.5, 119, 35, 4, 5], [0, 0, 40, 40, 30, 7], [0, 0, 10, 10, 0.2, 5], [3, 4, 80, 24, 12, 3]]) {
  add('roundRectPoly', [x, y, w, h, r, per], roundRectPoly(x, y, w, h, r, per))
}
add('pillPoly', [0, 0, 90, 30, 7], pillPoly(0, 0, 90, 30, 7))
add('ellipsePoly', [10, 20, 30, 12, 28, 0], ellipsePoly(10, 20, 30, 12, 28, 0))
add('ellipsePoly', [0, 0, 5, 9, 11, 0.7], ellipsePoly(0, 0, 5, 9, 11, 0.7))
for (const step of [4, 9.5]) add('densifyClosed', [tri, step], densifyClosed(tri, step))
for (const [seed, amp, wl] of [['wb1', 0.7, 18], ['wb2', 2, 24]] as const) {
  add('wobblePoly', [rect, seed, amp, wl], wobblePoly(rect, makeRng(seed), amp, wl))
}
for (const [d, dx, dy] of [[-0.9, 0.5, 0.6], [3, 0, 0], [-2, 0, 0]]) {
  add('offsetPoly', [rect, d, dx, dy], offsetPoly(rect, d, dx, dy))
  add('offsetPoly', [tri, d, dx, dy], offsetPoly(tri, d, dx, dy))
}
const spans = (poly: Pt[], angle: number, gap: number, seed: string, o: { jitter?: number; inset?: number; even?: boolean }) =>
  add('scanSpans', [poly, angle, gap, seed, o], scanSpans(poly, angle, gap, makeRng(seed), o))
spans(big, (60 * Math.PI) / 180, 4, 'sp1', { jitter: 0.15, even: false })
spans(big, 0.2, 7, 'sp2', {})
spans(blob, 1.3, 3, 'sp3', { inset: 2 })
spans(tri, -0.4, 50, 'sp4', { even: true })
spans(tri, 2.1, 2.2, 'sp5', { even: false, jitter: 0.3 })

const w = new PathWriter(20)
w.M(1.234, -5.5).L(1.25, -5.5).L(0.4, 0.45).Q(3, 3, -2.05, 7.5).Z().M(10, 10).L(10.05, 10.1).Z()
add('pathWriter', [], w.d)

writeFixture('packages/looseleaf_ink/test/fixtures/geom.json', { cases })
