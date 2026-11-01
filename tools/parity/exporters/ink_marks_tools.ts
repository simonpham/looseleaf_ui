// runRecipe frames of the tool recipes (sketchpad, sticker board and sheet, stepper, tear-off, typewriter caret,
// typing indicator) plus their helpers, for packages/looseleaf_ink/test/marks_tools_test.dart.
import {
  cleanPoints, clearStrokeCache, cursorMarkup, strokeBounds, strokeHit, strokeMarkup, svgDataUrl,
  type SketchStroke,
} from '@/lib/ink/recipes/sketchpad-ink'
import { wholeItems, type StickerBoardItem } from '@/lib/ink/recipes/sticker-board-ink'
import '@/lib/ink/recipes/sticker-sheet-ink'
import { tallyWidth } from '@/lib/ink/recipes/stepper-ink'
import '@/lib/ink/recipes/tear-off-ink'
import { typingPlan } from '@/lib/ink/recipes/typewriter-ink'
import { typingGeometry } from '@/lib/ink/recipes/typing-indicator-ink'
import { runCases, spread, type RecipeCase } from '../recipe_cases'
import { writeFixture } from '../write'

const cases: RecipeCase[] = []

// sketchpad
for (const tool of ['felt', 'brush', 'pencil', 'marker', 'highlighter', 'eraser']) {
  cases.push(...spread(`sketch tool ${tool}`, 'sketchpad-tool', 56, 48, { tool, color: 'ink' }))
  cases.push({ name: `sketch tool ${tool} teal`, recipe: 'sketchpad-tool', w: 44, h: 40, params: { tool, color: 'teal' } })
}
cases.push({ name: 'sketch tool highlighter red', recipe: 'sketchpad-tool', w: 56, h: 48, params: { tool: 'highlighter', color: 'red' } })
cases.push({ name: 'sketch tool pencil grape', recipe: 'sketchpad-tool', w: 56, h: 48, params: { tool: 'pencil', color: 'grape' } })
for (const color of ['ink', 'ink-you', 'hi', 'bubblegum']) cases.push(...spread(`sketch swatch ${color}`, 'sketchpad-swatch', 32, 32, { color }))
for (const size of ['fine', 'medium', 'bold']) cases.push(...spread(`sketch size ${size}`, 'sketchpad-size', 32, 32, { size }))
cases.push(...spread('sketch canvas', 'sketchpad-canvas', 320, 200, {}))

// sticker board and sheet
for (const [tag, params] of [['plain', { selected: false, handles: false }], ['selected', { selected: true, handles: false }], ['handles', { selected: true, handles: true }]] as const) {
  cases.push(...spread(`board item ${tag}`, 'sticker-board-item', 96, 80, params))
}
cases.push({ name: 'board item hover only', recipe: 'sticker-board-item', w: 60, h: 120, params: { selected: true, handles: true }, lazy: ['hover'] })
cases.push(...spread('sticker sheet', 'sticker-sheet', 300, 220, { top: 0 }))
cases.push({ name: 'sticker sheet top', recipe: 'sticker-sheet', w: 260, h: 180, params: { top: 30 } })
cases.push({ name: 'sticker sheet tiny', recipe: 'sticker-sheet', w: 30, h: 180, params: { top: 0 } })
cases.push(...spread('sticker slot', 'sticker-slot', 80, 80, {}))

// stepper
for (const [tag, params] of [
  ['rest', {}], ['plain', { plain: true }], ['invalid', { invalid: true }], ['disabled', { disabled: true }],
  ['invalid false', { invalid: false, disabled: false }],
] as const) {
  cases.push(...spread(`stepper ${tag}`, 'stepper', 140, 36, params))
  cases.push({ name: `stepper ${tag} narrow`, recipe: 'stepper', w: 60, h: 36, params })
}
cases.push({ name: 'stepper wide', recipe: 'stepper', w: 320, h: 40, params: {} })
for (const count of [0, 1, 4, 5, 7, 23, 80]) cases.push({ name: `stepper tally ${count}`, recipe: 'stepper-tally', w: 200, h: 20, params: { count } })
cases.push({ name: 'stepper tally short', recipe: 'stepper-tally', w: 100, h: 12, params: { count: 6 } })

// tear-off
cases.push(...spread('tear seam', 'tear-off-seam', 240, 16, {}))
cases.push({ name: 'tear seam vertical', recipe: 'tear-off-seam', w: 16, h: 200, params: {} })
cases.push({ name: 'tear seam no scissors', recipe: 'tear-off-seam', w: 240, h: 16, params: { scissors: false, inset: 2 } })
for (const toward of ['right', 'left', 'down']) cases.push(...spread(`tear hint ${toward}`, 'tear-off-hint', 40, 30, { toward }))
cases.push(...spread('tear stub', 'tear-off-stub', 120, 60, {}))

// typewriter and typing indicator
for (const shape of ['block', 'bar', 'underscore']) cases.push(...spread(`caret ${shape}`, 'typewriter-caret', 9, 20, { shape }))
for (const variant of ['dots', 'squiggle']) {
  cases.push(...spread(`typing ${variant}`, 'typing-indicator', 96, 28, { variant }))
  cases.push({ name: `typing ${variant} you no pencil`, recipe: 'typing-indicator', w: 72, h: 20, params: { variant, pen: 'you', pencil: false } })
  cases.push({ name: `typing ${variant} tall`, recipe: 'typing-indicator', w: 140, h: 44, params: { variant, pen: 'ink', pencil: true } })
}

const zig = (n: number, pressure: boolean, scale = 1): Array<[number, number] | [number, number, number]> =>
  Array.from({ length: n }, (_, i) => {
    const x = 10 + i * 3.1 * scale, y = 20 + Math.sin(i * 0.7) * 12 * scale
    return pressure ? [x, y, (i % 7) / 7] : [x, y]
  })

const strokes: SketchStroke[] = []
for (const tool of ['felt', 'brush', 'pencil', 'marker', 'highlighter'] as const) {
  strokes.push({ id: `s-${tool}`, tool, color: 'ink', size: 1, pts: zig(30, false) })
  strokes.push({ id: `p-${tool}`, tool, color: 'teal', size: 1.9, pts: zig(30, true) })
}
strokes.push({ id: 'dot', tool: 'felt', color: 'red', size: 0.6, pts: [[5, 5]] })
strokes.push({ id: 'two', tool: 'pencil', color: 'ink-you', size: 1, pts: [[5, 5], [5.5, 5.2]] })
strokes.push({ id: 'long', tool: 'felt', color: 'ink', size: 1, pts: zig(160, true, 0.9) })
strokes.push({ id: 'mixed', tool: 'brush', color: 'grape', size: 1, pts: [[0, 0], [1, 1, 0.3], [6, 6], [NaN, 3], [12, 2, 0.9], [12.3, 2.1]] })
strokes.push({ id: 'empty', tool: 'marker', color: 'hi', size: 1, pts: [] })

const pointCases = strokes.map((s) => ({ id: s.id, out: cleanPoints(s.pts) }))
const markup = strokes.flatMap((s) => [
  { id: s.id, tier: 'lo', live: false, out: strokeMarkup(s) },
  { id: s.id, tier: 'hi', live: false, out: strokeMarkup(s, { tier: 'hi' }) },
  { id: s.id, tier: 'lo', live: true, out: strokeMarkup(s, { live: true }) },
])
clearStrokeCache()
const bounds = strokes.map((s) => ({ id: s.id, out: strokeBounds(s) }))
const hits = strokes.flatMap((s) => [[10, 20, 2], [40, 30, 4], [5, 5, 1], [100, 100, 3], [30, 8, 0.5]].map(([x, y, r]) => ({ id: s.id, x, y, r, out: strokeHit(s, x, y, r) })))

const items: StickerBoardItem[] = [
  { id: 'a', name: 'cat', x: 10, y: 20, rot: 5, scale: 1.2, z: 1 },
  { id: 'b', name: 'dog', x: NaN, y: Infinity, rot: NaN, scale: -1, z: NaN },
  { id: 'c', name: 'sun', x: 3, y: 4, rot: 0, scale: NaN, z: 2 },
]
const whole = items.slice(0, 1)
const fin = (v: number) => (Number.isFinite(v) ? v : String(v))
const itemJson = (list: StickerBoardItem[]) => list.map((s) => ({ ...s, x: fin(s.x), y: fin(s.y), rot: fin(s.rot), scale: fin(s.scale), z: fin(s.z) }))

writeFixture('packages/looseleaf_ink/test/fixtures/marks_tools.json', {
  frames: runCases(cases),
  strokes: strokes.map((s) => ({ ...s, pts: s.pts.map((p) => p.map(fin)) })),
  cleanPoints: pointCases,
  strokeMarkup: markup,
  bounds,
  hits,
  cursor: ['a', 'b'].map((seed) => ({ seed, out: cursorMarkup(seed) })),
  dataUrl: ['<svg a="b & c">ü 🦊 (x)!*\'~</svg>'].map((svg) => ({ svg, out: svgDataUrl(svg) })),
  typingPlan: [
    { phrases: ['Hi there.', 'How are you, friend?'], o: { speed: 12, pause: 900, mode: 'lines', seed: 'a' } },
    { phrases: ['Hi there.', 'How are you, friend?'], o: { speed: 12, pause: 900, mode: 'lines', seed: 'a', loop: true } },
    { phrases: ['One', 'Two!', 'Three; four: five'], o: { speed: 20, pause: 500, mode: 'cycle', seed: 'b' } },
    { phrases: ['One', 'Two!'], o: { speed: 0.5, pause: 500, mode: 'cycle', seed: 'c', loop: true } },
  ].map((c) => ({ ...c, out: typingPlan(c.phrases, c.o as never) })),
  typingGeometry: [[96, 28], [40, 12], [200, 44]].flatMap(([w, h]) => (['dots', 'squiggle'] as const).map((v) => ({ w, h, variant: v, out: typingGeometry(w, h, v) }))),
  tallyWidth: [[0], [1], [5], [6], [23], [7, 10], [-3]].map(([count, gh]) => ({ count, gh, out: gh === undefined ? tallyWidth(count) : tallyWidth(count, gh) })),
  wholeItems: [
    { items: itemJson(items), out: itemJson(wholeItems(items)), same: wholeItems(items) === items },
    { items: itemJson(whole), out: itemJson(wholeItems(whole)), same: wholeItems(whole) === whole },
  ],
})
