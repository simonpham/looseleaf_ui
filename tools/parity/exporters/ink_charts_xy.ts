// XY charts: buildXY specs, capRows, looks, summaries and tables, and layoutXY with cursors, hits and steps,
// for packages/looseleaf_ink/test/charts_xy_test.dart.
import { buildXYRows, capRows, autoLook, seriesLook, toNum, type XYBuildInput, type Row } from '@/lib/ink/charts/chart-build'
import { summarizeXY, tableXY, announceRow } from '@/lib/ink/charts/chart-data'
import { layoutXY, pickTicks, stackRanges } from '@/lib/ink/charts/chart-xy'
import type { XYKind } from '@/lib/ink/charts/chart-types'
import { clean, dumpLayout } from '../charts_support'
import { writeFixture } from '../write'

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
const sales: Row[] = MONTHS.map((month, i) => ({ month, revenue: 1200 + Math.round(Math.sin(i / 2) * 400 + i * 60), cost: 800 + ((i * 137) % 300), profit: Math.round(Math.cos(i) * 250) }))
const gaps: Row[] = MONTHS.slice(0, 9).map((month, i) => ({ month, a: i % 4 === 2 ? null : (i * 7) % 11 - 4, b: i === 5 ? 'n/a' : i % 3 === 0 ? String(i * 2.5) : -(i % 5) * 1.5, c: i < 2 ? undefined : i * 0.37 }))
const tiny: Row[] = [{ x: 'Only', v: 42 }]
const strs: Row[] = [' 12 ', '0x1A', '1e2', '', 'abc', '-7.5', true, null, 3, '.5'].map((v, i) => ({ k: `r${i}`, v }))
const long: Row[] = Array.from({ length: 420 }, (_, i) => ({ t: i, y: Math.round(Math.sin(i / 9) * 50 + Math.sin(i / 31) * 30 + (i % 50 === 0 ? 40 : 0)), z: i % 97 === 0 ? null : Math.round(i / 5) }))
const many: Row[] = Array.from({ length: 300 }, (_, i) => ({ d: `d${i}`, p: (i * 31) % 47, q: (i * 17) % 23 }))
const huge: Row[] = Array.from({ length: 1700 }, (_, i) => ({ t: i, y: Math.round(Math.sin(i / 40) * 100 + ((i * 7919) % 13)) }))
const pts: Row[] = Array.from({ length: 70 }, (_, i) => ({ x: ((i * 37) % 101) / 3, y: ((i * 53) % 89) - 20, s: (i * 11) % 9, y2: i % 9 === 0 ? null : ((i * 29) % 61) / 2 }))
const big: Row[] = MONTHS.map((month, i) => ({ month, users: 120000 + i * 35000 + ((i * 7717) % 9000), share: 0.12 + i * 0.013 }))

interface Case { name: string; data: string; input: Omit<XYBuildInput, 'rows'>; fmt?: boolean; boxes: Array<[number, number, boolean?]> }
const DATA: Record<string, Row[]> = { sales, gaps, tiny, strs, long, many, huge, pts, big }
const S = (key: string, o: object = {}) => ({ key, ...o })
const B3: Array<[number, number, boolean?]> = [[240, 160], [420, 260], [720, 320, true]]
const cases: Case[] = [
  { name: 'bar grouped', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue'), S('cost')] }, boxes: B3 },
  { name: 'bar single values', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue', { name: 'Revenue' })], values: true }, boxes: [[720, 320], [420, 260], [900, 400]] },
  { name: 'bar negatives auto values', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('profit')] }, boxes: [[720, 320], [1400, 360]] },
  { name: 'bar stacked', data: 'sales', input: { xKey: 'month', kind: 'bar', stacked: true, series: [S('revenue'), S('cost'), S('profit')] }, boxes: B3 },
  { name: 'bar horizontal', data: 'sales', input: { xKey: 'month', kind: 'bar', horizontal: true, series: [S('revenue'), S('cost')], values: true }, boxes: B3 },
  { name: 'bar horizontal negatives', data: 'gaps', input: { xKey: 'month', kind: 'bar', horizontal: true, series: [S('a')], notes: [{ at: 'min', text: 'dip' }, { at: 'max', text: 'top', pen: 'green', shape: 'underline' }] }, boxes: [[420, 300], [700, 360]] },
  { name: 'line smooth', data: 'sales', input: { xKey: 'month', kind: 'line', series: [S('revenue'), S('cost')], notes: [{ at: 'max', text: 'Peak!' }, { at: 'Mar', series: 'cost', text: 'here', pen: 'blue', shape: 'none' }], refs: [{ y: 1500, label: 'target' }, { y: 900, pen: 'ink' }] }, boxes: B3 },
  { name: 'line step gaps', data: 'gaps', input: { xKey: 'month', kind: 'line', curve: 'step', series: [S('a'), S('b'), S('c')], dots: true, bands: [{ from: 'Feb', to: 'Apr', text: 'Q' }, { from: 7, to: 6 }] }, boxes: B3 },
  { name: 'line linear pinned', data: 'sales', input: { xKey: 'month', kind: 'line', curve: 'linear', series: [S('profit', { marker: 'square', dash: 'dotted' })], domain: [-500, 'auto'], zero: false, tickCount: 7 }, boxes: [[420, 260]] },
  { name: 'area', data: 'sales', input: { xKey: 'month', kind: 'area', series: [S('revenue'), S('cost')], notes: [{ at: 'last', text: 'now', dx: -30, dy: -20 }] }, boxes: B3 },
  { name: 'area stacked', data: 'gaps', input: { xKey: 'month', kind: 'area', stacked: true, series: [S('a'), S('b'), S('c')] }, boxes: B3 },
  { name: 'area stacked sales', data: 'sales', input: { xKey: 'month', kind: 'area', stacked: true, series: [S('revenue'), S('cost')], dots: 'auto' }, boxes: [[420, 260]] },
  { name: 'combo', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue'), S('cost', { kind: 'line', slot: 5 }), S('profit', { kind: 'area', pattern: 'dots' })], refs: [{ y: 0 }], notes: [{ at: 4, series: 1, text: 'combo note' }] }, boxes: B3 },
  { name: 'hidden and patterns off', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue'), S('cost'), S('profit')], hidden: ['cost'], patterns: false, grid: false, showY: false }, boxes: [[420, 260]] },
  { name: 'patterns on', data: 'sales', input: { xKey: 'month', kind: 'line', series: [S('revenue')], patterns: true, showX: false }, boxes: [[420, 260]] },
  { name: 'tiny', data: 'tiny', input: { xKey: 'x', kind: 'bar', series: [S('v')], notes: [{ at: 'first', text: 'one' }] }, boxes: [[240, 160], [420, 260]] },
  { name: 'tiny line', data: 'tiny', input: { xKey: 'x', kind: 'line', series: [S('v')] }, boxes: [[240, 160]] },
  { name: 'strings', data: 'strs', input: { xKey: 'k', kind: 'bar', series: [S('v')] }, boxes: [[420, 260]] },
  { name: 'long line', data: 'long', input: { xKey: 't', kind: 'line', series: [S('y'), S('z')] }, boxes: [[420, 260], [720, 320]] },
  { name: 'long area stacked', data: 'long', input: { xKey: 't', kind: 'area', stacked: true, series: [S('y'), S('z')], curve: 'linear' }, boxes: [[420, 260]] },
  { name: 'many bars', data: 'many', input: { xKey: 'd', kind: 'bar', series: [S('p'), S('q')] }, boxes: [[720, 320]] },
  { name: 'huge line', data: 'huge', input: { xKey: 't', kind: 'line', series: [S('y')] }, boxes: [[720, 320]] },
  { name: 'scatter', data: 'pts', input: { xKey: 'x', kind: 'scatter', series: [S('y'), S('y2', { name: 'Second' })], refs: [{ x: 12, label: 'x ref' }, { y: 10, label: 'y ref', pen: 'blue' }], notes: [{ at: 'max', text: 'outlier' }] }, boxes: B3 },
  { name: 'bubbles', data: 'pts', input: { xKey: 'x', kind: 'scatter', series: [S('y')], sizeKey: 's', xDomain: [0, 'auto'] }, boxes: [[420, 260]] },
  { name: 'big numbers', data: 'big', input: { xKey: 'month', kind: 'line', series: [S('users')] }, boxes: [[420, 260], [240, 300]] },
  { name: 'small fractions', data: 'big', input: { xKey: 'month', kind: 'bar', series: [S('share')], values: true }, boxes: [[720, 320]] },
  { name: 'custom format', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue')], values: true }, fmt: true, boxes: [[720, 320]] },
  { name: 'empty', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [] }, boxes: [[420, 260]] },
  { name: 'loading', data: 'sales', input: { xKey: 'month', kind: 'line', series: [S('revenue')], state: 'loading' }, boxes: [[420, 260]] },
  { name: 'no rows', data: 'tiny', input: { xKey: 'x', kind: 'line', series: [S('missing')], stateText: 'Nothing yet' }, boxes: [[420, 260]] },
  { name: 'values off', data: 'sales', input: { xKey: 'month', kind: 'bar', series: [S('revenue')], values: false, dots: false }, boxes: [[720, 320]] },
]

const fmtInput = (i: Omit<XYBuildInput, 'rows'>, fmt?: boolean): Omit<XYBuildInput, 'rows'> =>
  fmt ? { ...i, yFormat: (v) => `${v}%`, xFormat: (v, idx) => `#${idx}:${String(v)}`, valueFormat: (v) => `$${v}` } : i

const out = cases.map((c) => {
  const rows = DATA[c.data]
  const { spec, rows: drawn } = buildXYRows({ ...fmtInput(c.input, c.fmt), rows } as XYBuildInput)
  return {
    name: c.name,
    data: c.data,
    input: c.input,
    fmt: !!c.fmt,
    drawn: drawn.length,
    spec: clean(spec),
    summary: summarizeXY(spec, { kind: 'Chart', title: c.name }),
    summaryPlain: summarizeXY(spec, { kind: 'Bar chart' }),
    table: clean(tableXY(spec, { xHead: 'Month' })),
    layouts: c.boxes.map(([w, h, calm]) => ({ w, h, calm: !!calm, out: dumpLayout(layoutXY(spec, { w, h }, !!calm), true) })),
  }
})

const looks = (['bar', 'line', 'area', 'scatter'] as XYKind[]).flatMap((kind) =>
  [-1, 0, 1, 5, 7].flatMap((slot) => [1, 3].flatMap((drawn) => (['auto', true, false] as const).map((p) => ({ kind, slot, drawn, p, auto: autoLook(kind, slot, drawn, p), own: seriesLook(kind, slot, drawn, p, { pattern: 'cross', marker: 'auto', dash: 'dashdot' }) })))),
)
const nums = [0, 3.5, -2, NaN, Infinity, '7', ' 8.25 ', '', '  ', 'x', '0b101', '0o17', '0xff', '1e3', '+4', '-0x10', 'Infinity', true, null, undefined].map((v) => ({ v: v === undefined ? '__undefined' : typeof v === 'number' && !Number.isFinite(v) ? String(v) : v, num: typeof v === 'number' && !Number.isFinite(v), out: toNum(v) }))
const caps = [
  { rows: 'many', keys: ['p', 'q'], kind: 'bar', x: 'd' },
  { rows: 'many', keys: ['p', 'q', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'], kind: 'bar', x: 'd' },
  { rows: 'huge', keys: ['y'], kind: 'line', x: 't' },
  { rows: 'huge', keys: [], kind: 'area', x: 't' },
  { rows: 'pts', keys: ['y'], kind: 'scatter', x: 'x' },
].map((c) => {
  const r = capRows(DATA[c.rows], c.keys, c.kind as XYKind, c.x)
  return { ...c, out: clean({ rows: r.rows, total: r.total }) }
})
const stacks = [true, false].map((stacked) => ({ stacked, out: clean(stackRanges(out[3] ? (buildXYRows({ rows: gaps, xKey: 'month', kind: 'bar', series: [S('a'), S('b'), S('c')] }).spec.series) : [], stacked, 9)) }))
const T = (vs: number[]) => vs.map((v) => ({ v, label: String(v) }))
const picks = [
  [T([0, 10, 20, 30, 40, 50, 60]), [T([0, 20, 40, 60]), T([0, 30, 60])], 4, [0, 60]],
  [T([0, 10, 20, 30, 40, 50, 60]), [T([0, 25, 50])], 3, [0, 60]],
  [T([0, 1.5, 3, 4.5, 6, 7.5]), [], 3, [0, 7.5]],
  [T([0, 7, 14, 21, 28, 35, 42, 49]), [T([0, 21]), T([0, 14, 28, 42])], 3, [0, 49]],
  [T([1, 2]), undefined, 5, [1, 2]],
].map(([d, a, m, s]) => ({ d, a: a ?? null, m, s, out: pickTicks(d as never, a as never, m as number, s as [number, number]) }))
const announce = announceRow('Mar', [{ name: 'Revenue', value: '1,234' }, { name: 'Cost', value: '9' }])

writeFixture('packages/looseleaf_ink/test/fixtures/charts_xy.json', { data: DATA, looks, nums, caps, stacks, picks, announce })
// The cases go into parts under ~1 MB each.
const parts: Array<typeof out> = [[]]
let size = 0
for (const c of out) {
  const bytes = JSON.stringify(c, null, 1).length
  if (size + bytes > 700_000 && parts[parts.length - 1].length) (parts.push([]), (size = 0))
  parts[parts.length - 1].push(c)
  size += bytes
}
parts.forEach((cases, i) => writeFixture(`packages/looseleaf_ink/test/fixtures/charts_xy_${i + 1}.json`, { cases }))
