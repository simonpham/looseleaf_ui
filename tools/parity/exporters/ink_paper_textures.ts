// Paper backgrounds and SVG pattern/mask defs from textures.ts, for packages/looseleaf_ink/test/paper_textures_test.dart.
// Tile images are swapped for `{tile:<name>}` so the fixture holds ids and geometry only.
import {
  GRAIN_TILES, PAPER_TILES, paperBackground, deskBackground, paperCss, deskCss, textureCssVars, svgPatternDefs, svgMaskDefs, inkDefsSvg,
  type PaperTileName,
} from '@/lib/ink/textures'
import { writeFixture } from '../write'

// PAPER_DEF_TILES from paper/defs.tsx (a React module).
const PAPER_DEF_TILES: PaperTileName[] = ['fibre', 'relief', 'slip', 'kraft', 'cloud']

for (const [name, t] of Object.entries(PAPER_TILES)) (t as { uri: string }).uri = `{tile:${name}}`
for (const [name, t] of Object.entries(GRAIN_TILES)) (t as { uri: string }).uri = `{tile:${name}}`

const paper = [
  { stock: undefined, o: {} },
  { stock: 'paper', o: { seed: 'p1' } },
  { stock: 'kraft', o: { seed: 7 } },
  { stock: 'slip', o: { tooth: 'cold', seed: 'x' } },
  { stock: 'pink', o: { layers: { cloud: false, relief: true } } },
  { stock: '#fafafa', o: { tooth: 'fine', seed: 'desk:12', layers: { kraft: true } } },
].map(({ stock, o }) => ({ stock: stock ?? null, o, out: paperBackground(stock, o as never), css: paperCss(stock, o as never) }))
const desk = [{}, { vignette: 0.12, seed: 'd' }, { seed: 0 }].map((o) => ({ o, out: deskBackground(o), css: deskCss(o) }))
const vars = [textureCssVars(), textureCssVars(['cloud', 'linen'] as PaperTileName[])]
const patterns = [svgPatternDefs(), svgPatternDefs({ tiles: PAPER_DEF_TILES, prefix: 'pp' })]
const masks = [svgMaskDefs(), svgMaskDefs({ kinds: ['felt', 'stamp'], prefix: 'q', region: 'bbox' }), svgMaskDefs({ kinds: ['marker'], region: { x: -10, y: -20, width: 300.5, height: 400 } })]
const defs = [inkDefsSvg(), inkDefsSvg({ paper: true, prefix: 'z', kinds: ['waxy'] })]

writeFixture('packages/looseleaf_ink/test/fixtures/paper_textures.json', { defTiles: PAPER_DEF_TILES, paper, desk, vars, patterns, masks, defs })
