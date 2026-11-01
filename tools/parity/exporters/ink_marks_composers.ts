// The sketchpad and sticker board SVG composers (strokesToSvg, composeBoardSvg), for
// packages/looseleaf_ink/test/marks_composers_test.dart. Grain tile images are swapped for `{tile:<name>}`.
import { GRAIN_TILES } from '@/lib/ink/textures'
import { clearStrokeCache, strokesToSvg, type SketchStroke } from '@/lib/ink/recipes/sketchpad-ink'
import { composeBoardSvg, type StickerBoardItem } from '@/lib/ink/recipes/sticker-board-ink'
import { writeFixture } from '../write'

for (const [name, t] of Object.entries(GRAIN_TILES)) (t as { uri: string }).uri = `{tile:${name}}`

const zig = (n: number, pressure: boolean, dy = 0): Array<[number, number] | [number, number, number]> =>
  Array.from({ length: n }, (_, i) => {
    const x = 10 + i * 3.1, y = 20 + dy + Math.sin(i * 0.7) * 12
    return pressure ? [x, y, (i % 7) / 7] : [x, y]
  })

const strokes: SketchStroke[] = [
  { id: 'a', tool: 'felt', color: 'ink', size: 1, pts: zig(24, false) },
  { id: 'b', tool: 'pencil', color: 'teal', size: 0.6, pts: zig(20, true, 30) },
  { id: 'c', tool: 'highlighter', color: 'hi', size: 1.9, pts: zig(18, false, 60) },
  { id: 'd"&', tool: 'marker', color: 'red', size: 1, pts: zig(12, true, 90) },
  { id: 'e', tool: 'brush', color: 'grape', size: 1, pts: [[40, 40]] },
]
const resolve = (name: string) => (name === '--ll-ink' ? '#222' : name === '--ll-hi' ? '' : undefined)
const sketchCases = [
  { tag: 'all', strokes, o: { width: 320, height: 200 } },
  { tag: 'hi titled', strokes, o: { width: 320, height: 200, tier: 'hi' as const, title: 'My <sketch> & co', margin: 8, background: '#fff"' } },
  { tag: 'resolved', strokes: strokes.slice(0, 2), o: { width: 160, height: 90.5, resolve, background: '' } },
  { tag: 'highlighter only', strokes: strokes.slice(2, 3), o: { width: 100, height: 100, margin: 0.5, title: '' } },
  { tag: 'empty', strokes: [], o: { width: 10, height: 10 } },
]
clearStrokeCache()
const sketch = sketchCases.map((c) => ({ tag: c.tag, ids: c.strokes.map((s) => s.id), o: { ...c.o, resolve: !!c.o.resolve }, out: strokesToSvg(c.strokes, c.o) }))

const items: StickerBoardItem[] = [
  { id: 'one', name: 'smiley', x: 120, y: 90, rot: -8, scale: 1.25, z: 2 },
  { id: 'two', name: 'stamp-paid', x: 60.5, y: 40, rot: 12.3, scale: 0.8, z: 1 },
  { id: 'three', name: 'rocket', x: 200, y: 140, rot: 0, scale: 1, z: 2 },
  { id: 'four', name: 'no-such-sticker', x: 10, y: 10, rot: 0, scale: 1, z: 0 },
  { id: 'five', name: 'cat-loaf', x: NaN, y: 30, rot: 4, scale: -2, z: 0 },
]
const boardCases = [
  { tag: 'paper', items, o: { width: 320, height: 240, size: 96 } },
  { tag: 'transparent', items: items.slice(0, 2), o: { width: 200, height: 160.5, size: 64, background: null } },
  { tag: 'custom resolved', items: items.slice(1, 3), o: { width: 300, height: 200, size: 48, background: '#fafafa', resolve: (svg: string) => svg.replace(/var\(--ll-[a-z-]+\)/g, '#000') } },
  { tag: 'empty', items: [], o: { width: 50, height: 50, size: 64 } },
]
const fin = (v: number) => (Number.isFinite(v) ? v : String(v))
const board = boardCases.map((c) => ({
  tag: c.tag,
  items: c.items.map((s) => ({ ...s, x: fin(s.x), y: fin(s.y), rot: fin(s.rot), scale: fin(s.scale), z: fin(s.z) })),
  o: { ...c.o, resolve: !!c.o.resolve },
  out: composeBoardSvg(c.items, c.o as never),
}))

writeFixture('packages/looseleaf_ink/test/fixtures/marks_composers.json', { strokes, sketch, board })
