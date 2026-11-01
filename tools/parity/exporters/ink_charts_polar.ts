// Pie, radar, radial, gauge, spark, tally and heatmap layouts (via layoutChart) with cursors, hits and steps,
// plus the polar helpers, for packages/looseleaf_ink/test/charts_polar_test.dart.
import { layoutChart, type ChartSpec } from '@/lib/ink/charts/chart-layout'
import { angleOf, arcPts, sectorPoly, polar, deg } from '@/lib/ink/charts/chart-polar'
import { buildCalendar, buildGrid } from '@/lib/ink/charts/chart-heat'
import type { HeatSpec, PieSpec, RadarSpec, RadialSpec, GaugeSpec, SparkSpec, TallySpec } from '@/lib/ink/charts/chart-types'
import { clean, dumpLayout } from '../charts_support'
import { writeFixture } from '../write'

const slice = (key: string, value: number, slot: number, label?: string) => ({ key, name: key.toUpperCase(), slot, pattern: 'hatch' as const, value, ...(label ? { label } : {}) })
const pies: PieSpec[] = [
  { type: 'pie', slices: [slice('a', 30, 0), slice('b', 20, 1), slice('c', 45, 2), slice('d', 5, 3)], inner: 0, start: 0, labels: true, patterns: true, state: 'ready' },
  { type: 'pie', slices: [slice('a', 1, 0), slice('b', 0, 1), slice('c', -3, 2), slice('d', 2.5, 3, 'two and a half'), slice('e', 0.1, 4)], inner: 0.55, start: -90, labels: true, patterns: false, state: 'ready' },
  { type: 'pie', slices: [slice('solo', 7, 0)], inner: 1.2, start: 45, labels: false, patterns: true, state: 'ready' },
  { type: 'pie', slices: [], inner: 0.3, start: 0, labels: true, patterns: true, state: 'empty', stateText: 'Nothing' },
  { type: 'pie', slices: [slice('a', 3, 0)], inner: 0, start: 0, labels: true, patterns: true, state: 'loading' },
]
const series = (key: string, slot: number, values: Array<number | null>) => ({ key, name: key, slot, pattern: 'dots' as const, marker: 'triangle' as const, values })
const radars: RadarSpec[] = [
  { type: 'radar', axes: ['Speed', 'Power', 'Range', 'Cost', 'Comfort', 'Style'], series: [series('a', 0, [3, 4, 2, 5, 1, 4]), series('b', 1, [5, null, 3, 2, 4, 6])], max: 5, levels: 5, ringLabels: ['5', '4', '', '2', '1'], fill: true, patterns: true, dots: true, state: 'ready' },
  { type: 'radar', axes: ['A', 'B', 'C'], series: [series('x', 2, [1, 0.5, 2])], max: 0, levels: 2.6, ringLabels: [], fill: false, patterns: false, dots: false, state: 'ready' },
  { type: 'radar', axes: ['A', 'B'], series: [], max: 3, levels: 3, ringLabels: [], fill: true, patterns: true, dots: true, state: 'ready' },
  { type: 'radar', axes: ['A', 'B', 'C', 'D'], series: [series('x', 0, [1, 2, 3, 4])], max: 4, levels: 0, ringLabels: ['top'], fill: true, patterns: true, dots: true, state: 'loading' },
]
const ring = (key: string, value: number, max: number, slot: number) => ({ key, name: `${key} ring`, slot, pattern: 'solid' as const, value, max })
const radials: RadialSpec[] = [
  { type: 'radial', rings: [ring('move', 420, 600, 0), ring('exercise', 25, 30, 1), ring('stand', 13, 12, 2)], start: 0, end: 270, patterns: true, state: 'ready' },
  { type: 'radial', rings: [ring('a', 1, 0, 0), ring('b', NaN, 4, 1), ring('c', 2, 4, 2), ring('d', 3, 4, 3), ring('e', 4, 4, 4)], start: -90, end: 90, patterns: false, state: 'ready' },
  { type: 'radial', rings: [ring('a', 1, 2, 0)], start: 0, end: 360, patterns: true, state: 'ready' },
  { type: 'radial', rings: [], start: 0, end: 270, patterns: true, state: 'empty' },
]
const gauges: GaugeSpec[] = [
  { type: 'gauge', value: 72, min: 0, max: 100, zones: [{ to: 50, slot: 2, pattern: 'solid' }, { to: 80, slot: 3, pattern: 'hatch' }, { to: 120, slot: 5, pattern: 'cross' }], sweep: 180, ticks: 10, minLabel: '0', maxLabel: '100', patterns: true, state: 'ready' },
  { type: 'gauge', value: -5, min: -10, max: 10, zones: [{ to: -20, slot: 0, pattern: 'solid' }, { to: 0, slot: 1, pattern: 'dots' }], sweep: 270, ticks: 4.4, minLabel: 'low', maxLabel: 'high', patterns: false, state: 'ready' },
  { type: 'gauge', value: 3, min: 5, max: 5, zones: [], sweep: 240, ticks: 99, minLabel: '', maxLabel: '', patterns: true, state: 'loading' },
]
const sparks: SparkSpec[] = [
  { type: 'spark', variant: 'line', values: [3, 5, 2, 8, 6, 9, 4, 7], min: 2, max: 9, slot: 0, ends: true, extremes: true, state: 'ready' },
  { type: 'spark', variant: 'area', values: [1, null, 4, 5, null, null, 2, 3, 6], min: 0, max: 6, slot: 1, ends: false, extremes: false, state: 'ready' },
  { type: 'spark', variant: 'bar', values: [4, -2, 0, 7, null, 3], min: -2, max: 7, slot: 2, ends: true, extremes: false, state: 'ready' },
  { type: 'spark', variant: 'line', values: [5], min: 5, max: 5, slot: 3, ends: true, extremes: true, state: 'ready' },
  { type: 'spark', variant: 'line', values: [], min: 0, max: 1, slot: 0, ends: false, extremes: false, state: 'empty' },
]
const trow = (key: string, count: number, slot: number) => ({ key, name: key, slot, count })
const tallies: TallySpec[] = [
  { type: 'tally', rows: [trow('Apples', 13, 0), trow('Bananas', 7, 1), trow('Cherries', 22, 2)], unit: 0, totals: ['13', '7', '22'], state: 'ready' },
  { type: 'tally', rows: [trow('Visits', 1240, 0), trow('Signups', 87, 1), trow('Odd', NaN, 2)], unit: 0, totals: ['1,240', '87'], state: 'ready' },
  { type: 'tally', rows: [trow('A', 30, 0), trow('B', 4, 1)], unit: 5, totals: [], state: 'ready' },
  { type: 'tally', rows: [], unit: 0, totals: [], state: 'empty', stateText: 'Nobody yet' },
  { type: 'tally', rows: Array.from({ length: 9 }, (_, i) => trow(`Row ${i}`, i * i * 13, i)), unit: 0, totals: [], state: 'ready' },
]
const calRows = Array.from({ length: 200 }, (_, i) => ({ date: new Date(Date.UTC(2026, 0, 1) + i * 86_400_000).toISOString().slice(0, 10), value: (i * 7) % 13 === 0 ? 0 : (i * 37) % 11 }))
const cal = buildCalendar(calRows, { levels: 5 })
const cal2 = buildCalendar(calRows.slice(0, 40), { levels: 4, weekStart: 1, weeks: 10 })
const grid = buildGrid(Array.from({ length: 40 }, (_, i) => ({ row: `r${i % 5}`, col: `c${(i * 3) % 8}`, value: (i * 13) % 17 })), { levels: 5 })
const heat = (c: typeof cal, variant: 'calendar' | 'grid', o: Partial<HeatSpec> = {}): HeatSpec => ({
  type: 'heat', cols: c.cols, rows: c.rows, levels: c.levels, levelCount: 5, colLabels: c.colLabels, rowLabels: c.rowLabels, slot: 2, variant, legend: { less: 'Less', more: 'More' }, patterns: true, state: 'ready', ...o,
})
const heats: HeatSpec[] = [heat(cal, 'calendar'), heat(cal2, 'calendar', { legend: null, levelCount: 4 }), heat(grid, 'grid'), heat(grid, 'grid', { state: 'loading', stateText: 'wait' }), heat({ ...grid, rowLabels: [], colLabels: [] }, 'grid', { legend: null })]

const BOXES: Array<[number, number, boolean?]> = [[220, 160], [420, 280], [640, 360, true]]
const specs: ChartSpec[] = [...pies, ...radars, ...radials, ...gauges, ...sparks, ...tallies, ...heats]
const charts = specs.map((spec) => ({
  spec: clean(spec),
  layouts: (spec.type === 'spark' ? ([[120, 32], [80, 24], [300, 60]] as Array<[number, number, boolean?]>) : BOXES).map(([w, h, calm]) => ({ w, h, calm: !!calm, out: dumpLayout(layoutChart(spec, { w, h }, !!calm)) })),
}))

const helpers = {
  deg: [0, 90, -45, 270, 33.3].map((d) => deg(d)),
  polar: [[10, 20, 30, 0], [0, 0, 5, 1.3], [50, 50, 12.5, -2.2]].map(([a, b, c, d]) => polar(a, b, c, d)),
  angle: [[0, 0, 10, 0], [0, 0, 0, -10], [0, 0, -10, 0], [0, 0, 0, 10], [5, 5, 3, 9]].map(([a, b, c, d]) => angleOf(a, b, c, d)),
  arcs: [[50, 50, 40, 0, 1.2, 4], [0, 0, 100, -1, 2.5, 6], [10, 10, 2, 0, 0.1, 4]].map(([cx, cy, r, a0, a1, s]) => arcPts(cx, cy, r, a0, a1, s)),
  sectors: [[50, 50, 0, 40, 0, 1.2, 4], [50, 50, 20, 40, -0.5, 0.5, 6], [0, 0, 0.4, 9, 1, 2, 4]].map(([cx, cy, r0, r1, a0, a1, s]) => sectorPoly(cx, cy, r0, r1, a0, a1, s)),
}

writeFixture('packages/looseleaf_ink/test/fixtures/charts_polar.json', { charts, helpers })
