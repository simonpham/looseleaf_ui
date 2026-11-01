// runRecipe frames of the chart recipes (chart-ink: xy, pie, radar, radial, gauge, spark, tally, heat, mark) over
// every chart type at a few sizes, calm, hi tier, rtl and lazy-only, for packages/looseleaf_ink/test/chart_recipes_test.dart.
// Specs are written JSON-safe (clean) next to each frame; fixtures are split in parts under ~900 KB.
import { buildXYRows, type Row, type XYBuildInput } from '@/lib/ink/charts/chart-build'
import { buildCalendar, buildGrid } from '@/lib/ink/charts/chart-heat'
import type { GaugeSpec, HeatSpec, PieSpec, RadarSpec, RadialSpec, SparkSpec, TallySpec } from '@/lib/ink/charts/chart-types'
import '@/lib/ink/recipes/chart-ink/mark'
import '@/lib/ink/recipes/chart-ink/mini'
import '@/lib/ink/recipes/chart-ink/polar'
import '@/lib/ink/recipes/chart-ink/xy'
import { clean } from '../charts_support'
import { runCases, type RecipeCase } from '../recipe_cases'
import { writeFixture } from '../write'

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
const sales: Row[] = MONTHS.map((month, i) => ({ month, revenue: 1200 + Math.round(Math.sin(i / 2) * 400 + i * 60), cost: 800 + ((i * 137) % 300), profit: Math.round(Math.cos(i) * 250) }))
const gaps: Row[] = MONTHS.slice(0, 9).map((month, i) => ({ month, a: i % 4 === 2 ? null : (i * 7) % 11 - 4, b: i === 5 ? 'n/a' : i % 3 === 0 ? String(i * 2.5) : -(i % 5) * 1.5, c: i < 2 ? undefined : i * 0.37 }))
const tiny: Row[] = [{ x: 'Only', v: 42 }]
const long: Row[] = Array.from({ length: 220 }, (_, i) => ({ t: i, y: Math.round(Math.sin(i / 9) * 50 + Math.sin(i / 31) * 30), z: i % 97 === 0 ? null : Math.round(i / 5) }))
const many: Row[] = Array.from({ length: 40 }, (_, i) => ({ d: `d${i}`, p: (i * 31) % 47, q: (i * 17) % 23 }))
const pts: Row[] = Array.from({ length: 70 }, (_, i) => ({ x: ((i * 37) % 101) / 3, y: ((i * 53) % 89) - 20, s: (i * 11) % 9, y2: i % 9 === 0 ? null : ((i * 29) % 61) / 2 }))
const few: Row[] = Array.from({ length: 12 }, (_, i) => ({ x: i * 2.5, y: ((i * 7) % 11) - 3, s: (i % 4) + 1 }))
const DATA: Record<string, Row[]> = { sales, gaps, tiny, long, many, pts, few }
const S = (key: string, o: object = {}) => ({ key, ...o })

type Size = [number, number]
const B3: Size[] = [[240, 160], [420, 260], [720, 320]]
const B2: Size[] = [[300, 200], [560, 300]]
const xyCases: Array<{ name: string; data: string; input: Omit<XYBuildInput, 'rows'>; boxes: Size[] }> = [
  { name: 'bar grouped', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue'), S('cost')] }, boxes: B3 },
  { name: 'bar patterns', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue'), S('cost', { pattern: 'cross' }), S('profit', { pattern: 'dots' })], patterns: true }, boxes: B2 },
  { name: 'bar scribble lines', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue', { pattern: 'scribble' }), S('cost', { pattern: 'lines' })], patterns: true, values: true }, boxes: [[560, 300]] },
  { name: 'bar negatives', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('profit')] }, boxes: B2 },
  { name: 'bar stacked', data: 'sales', input: { xKey: 'month', kind: 'bar', stacked: true, series: [S('revenue'), S('cost'), S('profit')] }, boxes: B3 },
  { name: 'bar horizontal', data: 'sales', input: { xKey: 'month', kind: 'bar', horizontal: true, series: [S('revenue'), S('cost')], values: true }, boxes: B3 },
  { name: 'bar horizontal negatives', data: 'gaps', input: { xKey: 'month', kind: 'bar', horizontal: true, series: [S('a')], notes: [{ at: 'min', text: 'dip' }, { at: 'max', text: 'top', pen: 'green', shape: 'underline' }] }, boxes: B2 },
  { name: 'many bars', data: 'many', input: { xKey: 'd', kind: 'bar', series: [S('p'), S('q')] }, boxes: B2 },
  { name: 'line smooth', data: 'sales', input: { xKey: 'month', kind: 'line', series: [S('revenue'), S('cost')], notes: [{ at: 'max', text: 'Peak!' }, { at: 'Mar', series: 'cost', text: 'here', pen: 'blue', shape: 'none' }], refs: [{ y: 1500, label: 'target' }, { y: 900, pen: 'ink' }] }, boxes: B3 },
  { name: 'line dashes', data: 'sales', input: { xKey: 'month', kind: 'line', patterns: true, series: [S('revenue', { dash: 'dashed' }), S('cost', { dash: 'dotted', marker: 'diamond' }), S('profit', { dash: 'dashdot', marker: 'cross' })], dots: true }, boxes: B2 },
  { name: 'line step gaps', data: 'gaps', input: { xKey: 'month', kind: 'line', curve: 'step', series: [S('a'), S('b'), S('c')], dots: true, bands: [{ from: 'Feb', to: 'Apr', text: 'Q' }, { from: 7, to: 6 }] }, boxes: B3 },
  { name: 'long line', data: 'long', input: { xKey: 't', kind: 'line', series: [S('y'), S('z')] }, boxes: B2 },
  { name: 'area', data: 'sales', input: { xKey: 'month', kind: 'area', series: [S('revenue'), S('cost')], notes: [{ at: 'last', text: 'now', dx: -30, dy: -20 }] }, boxes: B3 },
  { name: 'area stacked', data: 'gaps', input: { xKey: 'month', kind: 'area', stacked: true, series: [S('a'), S('b'), S('c')] }, boxes: B2 },
  { name: 'combo', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue'), S('cost', { kind: 'line', slot: 5 }), S('profit', { kind: 'area', pattern: 'dots' })], refs: [{ y: 0 }], notes: [{ at: 4, series: 1, text: 'combo note' }] }, boxes: B3 },
  { name: 'combo patterns no grid', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue'), S('cost', { kind: 'line', marker: 'square' })], patterns: true, grid: false, showY: false }, boxes: [[420, 260]] },
  { name: 'scatter', data: 'pts', input: { xKey: 'x', kind: 'scatter', series: [S('y'), S('y2', { name: 'Second' })], refs: [{ x: 12, label: 'x ref' }, { y: 10, label: 'y ref', pen: 'blue' }], notes: [{ at: 'max', text: 'outlier' }] }, boxes: B3 },
  { name: 'scatter few', data: 'few', input: { xKey: 'x', kind: 'scatter', series: [S('y', { marker: 'triangle' })], patterns: true }, boxes: B2 },
  { name: 'scatter few circles', data: 'few', input: { xKey: 'x', kind: 'scatter', series: [S('y')] }, boxes: [[420, 260]] },
  { name: 'bubbles', data: 'pts', input: { xKey: 'x', kind: 'scatter', series: [S('y')], sizeKey: 's', xDomain: [0, 'auto'] }, boxes: B2 },
  { name: 'bubbles few', data: 'few', input: { xKey: 'x', kind: 'scatter', series: [S('y')], sizeKey: 's' }, boxes: [[420, 260]] },
  { name: 'tiny', data: 'tiny', input: { xKey: 'x', kind: 'bar', series: [S('v')], notes: [{ at: 'first', text: 'one' }] }, boxes: [[240, 160]] },
  { name: 'tiny line', data: 'tiny', input: { xKey: 'x', kind: 'line', series: [S('v')] }, boxes: [[240, 160]] },
  { name: 'empty', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [] }, boxes: B2 },
  { name: 'loading', data: 'sales', input: { xKey: 'month', kind: 'line', series: [S('revenue')], state: 'loading' }, boxes: B2 },
  { name: 'no rows', data: 'tiny', input: { xKey: 'x', kind: 'line', series: [S('missing')], stateText: 'Nothing yet' }, boxes: [[420, 260]] },
]

const slice = (key: string, value: number, slot: number, pattern = 'hatch') => ({ key, name: key.toUpperCase(), slot, pattern, value })
const pies: PieSpec[] = [
  { type: 'pie', slices: [slice('a', 30, 0), slice('b', 20, 1, 'cross'), slice('c', 45, 2, 'dots'), slice('d', 5, 3, 'scribble')] as never, inner: 0, start: 0, labels: true, patterns: true, state: 'ready' },
  { type: 'pie', slices: Array.from({ length: 9 }, (_, i) => slice(`s${i}`, i + 1, i, 'lines')) as never, inner: 0.55, start: -90, labels: true, patterns: true, state: 'ready' },
  { type: 'pie', slices: [slice('solo', 7, 0)] as never, inner: 0.4, start: 45, labels: false, patterns: false, state: 'ready' },
  { type: 'pie', slices: [], inner: 0.3, start: 0, labels: true, patterns: true, state: 'empty', stateText: 'Nothing' },
  { type: 'pie', slices: [slice('a', 3, 0)] as never, inner: 0, start: 0, labels: true, patterns: true, state: 'loading' },
]
const series = (key: string, slot: number, values: Array<number | null>, marker = 'triangle', pattern = 'dots') => ({ key, name: key, slot, pattern, marker, values })
const radars: RadarSpec[] = [
  { type: 'radar', axes: ['Speed', 'Power', 'Range', 'Cost', 'Comfort', 'Style'], series: [series('a', 0, [3, 4, 2, 5, 1, 4]), series('b', 1, [5, null, 3, 2, 4, 6], 'square', 'hatch')] as never, max: 5, levels: 5, ringLabels: ['5', '4', '', '2', '1'], fill: true, patterns: true, dots: true, state: 'ready' },
  { type: 'radar', axes: ['A', 'B', 'C', 'D', 'E'], series: [0, 1, 2, 3].map((k) => series(`s${k}`, k, [1 + k, 2, 3 - k * 0.5, 2.5, 1])) as never, max: 4, levels: 4, ringLabels: [], fill: true, patterns: false, dots: true, state: 'ready' },
  { type: 'radar', axes: ['A', 'B', 'C'], series: [series('x', 2, [1, 0.5, 2])] as never, max: 0, levels: 2.6, ringLabels: [], fill: false, patterns: false, dots: false, state: 'ready' },
  { type: 'radar', axes: ['A', 'B'], series: [], max: 3, levels: 3, ringLabels: [], fill: true, patterns: true, dots: true, state: 'ready' },
  { type: 'radar', axes: ['A', 'B', 'C', 'D'], series: [series('x', 0, [1, 2, 3, 4])] as never, max: 4, levels: 0, ringLabels: ['top'], fill: true, patterns: true, dots: true, state: 'loading' },
]
const ring = (key: string, value: number, max: number, slot: number, pattern = 'solid') => ({ key, name: `${key} ring`, slot, pattern, value, max })
const radials: RadialSpec[] = [
  { type: 'radial', rings: [ring('move', 420, 600, 0), ring('exercise', 25, 30, 1, 'hatch'), ring('stand', 13, 12, 2, 'dots')] as never, start: 0, end: 270, patterns: true, state: 'ready' },
  { type: 'radial', rings: [ring('a', 1, 0, 0), ring('b', 0, 4, 1), ring('c', 2, 4, 2), ring('d', 3, 4, 3), ring('e', 4, 4, 4)] as never, start: -90, end: 90, patterns: false, state: 'ready' },
  { type: 'radial', rings: [ring('a', 1, 2, 0, 'cross')] as never, start: 0, end: 360, patterns: true, state: 'ready' },
  { type: 'radial', rings: [], start: 0, end: 270, patterns: true, state: 'empty' },
]
const gauges: GaugeSpec[] = [
  { type: 'gauge', value: 72, min: 0, max: 100, zones: [{ to: 50, slot: 2, pattern: 'solid' }, { to: 80, slot: 3, pattern: 'hatch' }, { to: 120, slot: 5, pattern: 'cross' }], sweep: 180, ticks: 10, minLabel: '0', maxLabel: '100', patterns: true, state: 'ready' },
  { type: 'gauge', value: -5, min: -10, max: 10, zones: [{ to: -20, slot: 0, pattern: 'solid' }, { to: 0, slot: 1, pattern: 'dots' }], sweep: 270, ticks: 4.4, minLabel: 'low', maxLabel: 'high', patterns: false, state: 'ready' },
  { type: 'gauge', value: 64, min: 0, max: 100, zones: [], sweep: 240, ticks: 5, minLabel: '0', maxLabel: '100', patterns: true, state: 'ready' },
  { type: 'gauge', value: 0, min: 0, max: 100, zones: [], sweep: 180, ticks: 0, minLabel: '', maxLabel: '', patterns: true, state: 'ready' },
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
  { type: 'tally', rows: [trow('Visits', 1240, 0), trow('Signups', 87, 1)], unit: 0, totals: ['1,240', '87'], state: 'ready' },
  { type: 'tally', rows: Array.from({ length: 6 }, (_, i) => trow(`Row ${i}`, i * i * 3, i)), unit: 0, totals: [], state: 'ready' },
  { type: 'tally', rows: [], unit: 0, totals: [], state: 'empty', stateText: 'Nobody yet' },
]
const calRows = Array.from({ length: 120 }, (_, i) => ({ date: new Date(Date.UTC(2026, 0, 1) + i * 86_400_000).toISOString().slice(0, 10), value: (i * 7) % 13 === 0 ? 0 : (i * 37) % 11 }))
const cal = buildCalendar(calRows, { levels: 5 })
const grid = buildGrid(Array.from({ length: 40 }, (_, i) => ({ row: `r${i % 5}`, col: `c${(i * 3) % 8}`, value: (i * 13) % 17 })), { levels: 5 })
const heat = (c: typeof cal, variant: 'calendar' | 'grid', o: Partial<HeatSpec> = {}): HeatSpec => ({
  type: 'heat', cols: c.cols, rows: c.rows, levels: c.levels, levelCount: 5, colLabels: c.colLabels, rowLabels: c.rowLabels, slot: 2, variant, legend: { less: 'Less', more: 'More' }, patterns: true, state: 'ready', ...o,
})
const heats: HeatSpec[] = [heat(cal, 'calendar'), heat(grid, 'grid', { legend: null, levelCount: 4, slot: 4 }), heat(grid, 'grid', { state: 'loading', stateText: 'wait' })]

const cases: RecipeCase[] = []
const specOf: Record<string, unknown> = {}
const add = (recipe: string, name: string, params: unknown, boxes: Size[]) => {
  specOf[name] = params
  boxes.forEach(([w, h], i) => {
    cases.push({ name: `${name} ${w}x${h}`, recipe, w, h, params })
    if (i === boxes.length - 1) {
      cases.push({ name: `${name} ${w}x${h} calm`, recipe, w, h, params, density: 'calm' })
      cases.push({ name: `${name} ${w}x${h} hi`, recipe, w, h, params, tier: 'hi' })
    }
  })
}
for (const c of xyCases) add('chart-xy', `xy ${c.name}`, buildXYRows({ ...c.input, rows: DATA[c.data] } as XYBuildInput).spec, c.boxes)
const RB: Size[] = [[220, 160], [420, 280], [640, 360]]
pies.forEach((s, i) => add('chart-pie', `pie ${i}`, s, RB))
radars.forEach((s, i) => add('chart-radar', `radar ${i}`, s, RB))
radials.forEach((s, i) => add('chart-radial', `radial ${i}`, s, RB))
gauges.forEach((s, i) => add('chart-gauge', `gauge ${i}`, s, RB))
sparks.forEach((s, i) => add('chart-spark', `spark ${i}`, s, [[120, 32], [80, 24], [300, 60]]))
tallies.forEach((s, i) => add('chart-tally', `tally ${i}`, s, [[260, 140], [480, 220]]))
heats.forEach((s, i) => add('chart-heat', `heat ${i}`, s, [[420, 160], [720, 220]]))
for (const recipe of ['chart-xy', 'chart-pie']) {
  const name = recipe === 'chart-xy' ? 'xy bar grouped' : 'pie 0'
  cases.push({ name: `${name} rtl`, recipe, w: 420, h: 260, params: specOf[name], dir: 'rtl' })
  cases.push({ name: `${name} compact`, recipe, w: 420, h: 260, params: specOf[name], density: 'compact' })
  cases.push({ name: `${name} lazy only`, recipe, w: 420, h: 260, params: specOf[name], lazyOnly: true })
}

const marks: Array<[string, unknown, Size]> = [
  ...(['solid', 'hatch', 'dots', 'cross', 'lines', 'scribble'] as const).map((pattern, slot): [string, unknown, Size] => [`swatch ${pattern}`, { kind: 'swatch', slot, pattern }, [14, 14]]),
  ['swatch big', { kind: 'swatch', slot: 0, pattern: 'hatch' }, [40, 28]],
  ['swatch line', { kind: 'swatch', slot: 1, pattern: 'solid', line: true }, [24, 12]],
  ['swatch line dashed marker', { kind: 'swatch', slot: 2, pattern: 'dots', line: true, dash: 'dashed', marker: 'triangle' }, [28, 14]],
  ['swatch line dotted none', { kind: 'swatch', slot: 3, pattern: 'solid', line: true, dash: 'dotted', marker: 'none' }, [28, 14]],
  ['swatch line dashdot circle', { kind: 'swatch', slot: 4, pattern: 'solid', line: true, dash: 'dashdot', marker: 'circle' }, [40, 16]],
  ['swatch line false', { kind: 'swatch', slot: 5, pattern: 'cross', line: false }, [16, 16]],
  ['column', { kind: 'column' }, [30, 200]],
  ['column wide', { kind: 'column', slot: 2 }, [300, 26]],
  ['guide', { kind: 'guide' }, [8, 220]],
  ['ring', { kind: 'ring', slot: 3 }, [16, 16]],
  ['slice', { kind: 'slice', cx: 100, cy: 100, r0: 0, r1: 90, a0: 0.3, a1: 1.4 }, [200, 200]],
  ['slice donut', { kind: 'slice', cx: 80, cy: 80, r0: 40, r1: 75, a0: -0.5, a1: 2 }, [160, 160]],
  ['cell', { kind: 'cell' }, [18, 18]],
  ['spoke', { kind: 'spoke', x1: 50, y1: 50, x2: 90, y2: 10 }, [100, 100]],
]
for (const [name, params, [w, h]] of marks) {
  cases.push({ name: `mark ${name}`, recipe: 'chart-mark', w, h, params })
  cases.push({ name: `mark ${name} calm`, recipe: 'chart-mark', w, h, params, density: 'calm' })
}

const frames = runCases(cases).map((f) => ({ ...(f as object), params: clean((f as { params: unknown }).params) }))
const parts: Array<typeof frames> = [[]]
let size = 0
for (const f of frames) {
  const bytes = JSON.stringify(f, null, 1).length
  if (size + bytes > 850_000 && parts[parts.length - 1].length) (parts.push([]), (size = 0))
  parts[parts.length - 1].push(f)
  size += bytes
}
parts.forEach((p, i) => writeFixture(`packages/looseleaf_ink/test/fixtures/chart_recipes_${i + 1}.json`, { frames: p }))
