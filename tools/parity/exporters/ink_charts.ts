// Chart scales, formats, text measure, curves and heatmap data, for packages/looseleaf_ink/test/charts_test.dart.
import {
  bucketOf, round, niceScale, ticksIn, coarserTicks, shares, radarRim, formatNumber, formatCompact, formatPercent, textWidth, labelWidth,
  pickLabelIndices, clearLabels, monotoneCurve, stepCurve, lttb, thinIndices, strideIndices, clampN,
} from '@/lib/ink/charts/chart-scale'
import { slotKey, defaultPattern, defaultMarker, defaultDash } from '@/lib/ink/charts/chart-types'
import { dayMs, isoDay, formatDay, levelOf, buildCalendar, buildGrid } from '@/lib/ink/charts/chart-heat'
import type { Pt } from '@/lib/ink/types'
import { clean, enc } from '../charts_support'
import { writeFixture } from '../write'

const NUMS = [0, -0, 1, -1, 0.5, 0.1 + 0.2, 7, 9.95, 10, 99.5, 100, 999, 999.5, 1000, 1234.5678, 12345, 99999, 1e5, 999999, 1e6, 2.5e6, 1e9, 3.3e12, -4567.891, 1e-7, 0.000123, 1e21, NaN, Infinity]
const log10 = [1e-12, 1e-7, 0.000123, 0.001, 0.01, 0.1, 0.3, 0.5, 1, 2, 3, 5, 9.99, 10, 99, 100, 1000, 1e4, 1e5, 1e6, 1e9, 1e15, 1e22, 123456.789, 0.07, 7.5e-5].map((x) => [x, Math.log10(x), 10 ** Math.floor(Math.log10(x))])
const scales = [
  [0, 10, 5], [0, 1, 5], [-3.2, 17.9, 5], [0.001, 0.0042, 4], [5, 5, 5], [0, 0, 5], [-7, -7, 3], [3, 3, 6], [12, 980, 6], [-1e6, 2.5e6, 5],
  [0.1, 0.7, 5], [100, 101, 5], [NaN, 4, 5], [1, Infinity, 5], [0, 1234567, 8], [-0.5, 0.5, 2], [0, 37, 12], [2, 1, 5],
].map(([a, b, c]) => ({ a: enc(a), b: enc(b), c, out: niceScale(a, b, c) }))
const ticks = [[0, 10, 5], [0, 1, 4], [-3.2, 17.9, 3], [0.3, 0.9, 5], [5, 5, 5], [7, 3, 5], [0, 1234567, 2], [-12.5, 260, 6]].map(([a, b, c]) => ({ a, b, c, out: ticksIn(a, b, c) }))
const coarser = [[0, 100, [0, 20, 40, 60, 80, 100]], [0, 1, [0, 0.2, 0.4, 0.6, 0.8, 1]], [-5, 35, [-5, 0, 5, 10, 15, 20, 25, 30, 35]], [0, 3, [0, 1, 2, 3]]].map(([a, b, d]) => ({ a, b, d, out: coarserTicks(a as number, b as number, d as number[]) }))
const shareCases = [[[1, 1, 1], 0], [[1, 1, 1], 1], [[50, 30, 20], 0], [[0, 0], 0], [[3, -1, NaN, 7, 0.5], 0], [[1, 2, 3, 4, 5, 6, 7], 2], [[33.3, 33.3, 33.4], 0]].map(([v, d]) => ({ v: enc(v), d, out: shares(v as number[], d as number) }))
const rims = [[0, 4], [-3, 4], [7.3, 4], [100, 5], [0.042, 3], [987654, 6], [1, 0], [55, 4.6], [NaN, 4]].map(([t, l]) => ({ t: enc(t), l, out: radarRim(t, l) }))
const formats = NUMS.map((v) => ({ v: enc(v), number: formatNumber(v), number0: formatNumber(v, 0), number4: formatNumber(v, 4), compact: formatCompact(v), pct: formatPercent(v), pct1: formatPercent(v, 1), round: clean(round(v)), round0: clean(round(v, 0)), round10: clean(round(v, 10)) }))
const TEXTS = ['', 'Jan', 'January 2026', 'il.,:;!|', 'MWmw%@', 'Hello World', 'émoji 🦊 ok', "it's", '12,345.67', 'ALL CAPS']
const texts = TEXTS.map((s) => ({ s, script: textWidth(s, 15), hand: textWidth(s, 12.5, 'hand'), mono: textWidth(s, 13, 'mono'), label: labelWidth(s, 16) }))
const picks = [
  [[30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30], 40], [[30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30], 25], [[20, 60, 20, 60, 20, 60, 20], 33],
  [Array.from({ length: 31 }, (_, i) => 12 + (i % 3) * 5), 9], [[50], 10], [[], 10], [Array.from({ length: 13 }, () => 40), 18], [Array.from({ length: 100 }, () => 22), 4.1],
].map(([w, p]) => ({ w, p, out: pickLabelIndices(w as number[], p as number) }))
const clears = [
  [[0, 20], [30, 20], [55, 20], [80, 20], [100, 20]], [[0, 50], [40, 50], [90, 50], [130, 30]], [[10, 10]], [], [[0, 30], [20, 30], [40, 30], [60, 30], [70, 30]],
].map((xs) => {
  const items = xs.map(([x, w]) => ({ x, w }))
  return { items, out: clearLabels(items) }
})
const ZIG: Pt[] = [[0, 10], [20, 30], [45, 5], [60, 5], [90, 40], [91, 38], [130, 0]]
const curves = [ZIG, [[0, 0], [10, 10]], [[0, 0], [0, 10], [5, 3]], [[0, 5], [10, 5], [20, 5], [30, 6]], [[0, 0], [5, 100], [10, 0], [15, 100]]].map((pts) => ({
  pts, mono: monotoneCurve(pts as Pt[]), mono3: monotoneCurve(pts as Pt[], 3), step: stepCurve(pts as Pt[]),
}))
const wave = Array.from({ length: 300 }, (_, i) => [i, Math.sin(i / 7) * 40 + Math.cos(i / 23) * 25 + (i % 17 === 0 ? 30 : 0)] as Pt)
const lttbs = [[300, 50], [300, 3], [300, 2], [300, 400], [40, 10]].map(([n, t]) => ({ n, t, out: lttb(wave.slice(0, n), t) }))
const thins = [[10, 4], [100, 7], [5, 10], [50, 1], [1000, 13]].map(([n, m]) => ({ n, m, thin: thinIndices(n, m), stride: strideIndices(n, m) }))
const misc = {
  buckets: [0, 279.9, 280, 559, 560, 1200].map((w) => bucketOf(w)),
  clamps: [[5, 0, 1], [-1, 0, 1], [0.5, 0, 1], [NaN, 0, 1]].map(([v, a, b]) => ({ v: enc(v), a, b, out: clean(clampN(v, a, b)) })),
  slots: [-9, -1, 0, 3, 7, 8, 15, 100].map((s) => [slotKey(s), defaultPattern(s), defaultMarker(s), defaultDash(s)]),
}

const DATES = ['2026-03-15', '2026-03-15T23:59:59Z', '1999-12-31', '2026-13-45', 'nope', '2026-1-5', '', '0099-01-01']
const dates = DATES.map((d) => ({ d, ms: enc(dayMs(d)) }))
const days = [0, 1767225600000, 1773532800000, 946598400000, 1709164800000].map((ms) => ({ ms, iso: isoDay(ms), day: formatDay(ms), dayYear: formatDay(ms, true) }))
const levels = [[0, 10, 5], [3, 10, 5], [10, 10, 5], [12, 10, 5], [0.001, 10, 4], [-2, 10, 5], [5, 0, 5], [NaN, 10, 5], [null, 10, 5]].flatMap(([v, m, l]) =>
  [undefined, [1, 5, 10], []].map((t) => ({ v, m, l, t: t ?? null, out: levelOf(v as number | null, m as number, l as number, t) })),
)
const calRows = Array.from({ length: 140 }, (_, i) => {
  const ms = Date.UTC(2026, 0, 1) + i * 2 * 86_400_000 + (i % 3) * 86_400_000
  const value = i % 11 === 0 ? 'x' : i % 7 === 0 ? String((i * 13) % 9) : (i * 7) % 12
  return { date: new Date(ms).toISOString().slice(0, 10), value }
})
const calendars = [
  { o: { levels: 5 } },
  { o: { levels: 5, weekStart: 1, weeks: 20 } },
  { o: { levels: 4, end: '2026-06-30', thresholds: [1, 4, 8], monthLabels: false } },
  { o: { levels: 5, weeks: 2, end: '2026-02-03', weekdayLabels: false } },
  { o: { levels: 5, weeks: 70 } },
  { o: { levels: 3, end: '2025-12-31' } },
].map(({ o }) => ({ o, out: clean(buildCalendar(calRows, o as never)) }))
const emptyCal = clean(buildCalendar([], { levels: 5 }))
const gridData = Array.from({ length: 60 }, (_, i) => ({ row: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'][i % 5], col: (i * 7) % 12, value: i % 9 === 0 ? 'n/a' : (i * 37) % 23 }))
const grids = [
  { o: { levels: 5 } },
  { o: { levels: 4, rows: ['Fri', 'Mon', 'Sun'], cols: ['0', '7', '2', '99'] } },
  { o: { levels: 5, thresholds: [5, 10, 20] } },
].map(({ o }) => ({ o, out: clean(buildGrid(gridData, o as never)) }))

writeFixture('packages/looseleaf_ink/test/fixtures/charts.json', {
  log10, scales: clean(scales), ticks, coarser, shares: shareCases, rims, formats, texts, picks, clears, curves, lttbs, thins, misc,
  heat: { calRows, dates, days, levels, calendars, emptyCal, gridData, grids },
})
