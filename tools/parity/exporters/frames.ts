// Per-layer markup of a broad sample of recipes and art, for the painter tests in looseleaf_ui.
import { readdirSync } from 'node:fs'
import { join } from 'node:path'
import { pathToFileURL } from 'node:url'

import { allRecipes, getRecipe, DEFAULT_KNOBS, runRecipe, type Box, type InkLayerName } from '@/lib/ink/recipes'
import { drawSkeleton, renderSticker } from '@/lib/ink/art-draw'
import { icons } from '@/lib/ink/art/icons'
import { doodles } from '@/lib/ink/art/doodles'
import { stickers } from '@/lib/ink/art/stickers'
import { stickerFace, kissCut } from '@/lib/ink/recipes/sticker-ink'
import { sealArt } from '@/lib/ink/recipes/seal-ink'
import { buildXY } from '@/lib/ink/charts/chart-build'
import type { ArtDef, StickerDef } from '@/lib/ink/art/types'
import { writeFixture } from '../write'

interface FrameFixture {
  name: string
  recipe?: string
  w: number
  h: number
  pad: number
  layers: string[]
  parts: Record<string, string>
}

const recipesDir = join(process.cwd(), 'src/lib/ink/recipes')
const skippedModules: string[] = []
async function load(file: string): Promise<void> {
  try {
    await import(pathToFileURL(file).href)
  } catch {
    skippedModules.push(file)
  }
}
for (const entry of readdirSync(recipesDir, { withFileTypes: true })) {
  if (entry.isDirectory()) {
    for (const f of readdirSync(join(recipesDir, entry.name))) if (f.endsWith('.ts')) await load(join(recipesDir, entry.name, f))
  } else if (entry.name.endsWith('-ink.ts')) {
    await load(join(recipesDir, entry.name))
  }
}
if (skippedModules.length) console.log(`    skipped (need react): ${skippedModules.length}`)

const frames: FrameFixture[] = []

function run(name: string, id: string, box: Box, params: unknown): void {
  const recipe = getRecipe(id)
  if (!recipe) {
    console.log(`    no recipe ${id}`)
    return
  }
  const raw = runRecipe(recipe as never, {
    box, params: params as never, seed: name, tier: 'lo', density: 'comfortable', dir: 'ltr', knobs: DEFAULT_KNOBS,
    lazy: recipe.lazy as InkLayerName[],
  })
  if (!Number.isFinite(raw.pad)) {
    console.log(`    ${name}: no finite pad, skipped`)
    return
  }
  frames.push({ name, recipe: id, w: raw.w, h: raw.h, pad: raw.pad, layers: raw.layers, parts: raw.parts as Record<string, string> })
}

function art(name: string, res: { svg: string; w: number; h: number }): void {
  frames.push({ name, w: res.w, h: res.h, pad: 0, layers: ['rest'], parts: { rest: res.svg } })
}

run('button-default', 'button', { w: 120, h: 40 }, { variant: 'default', size: 'default' })
run('button-outline', 'button', { w: 120, h: 40 }, { variant: 'outline', size: 'default' })
run('button-secondary', 'button', { w: 120, h: 40 }, { variant: 'secondary', size: 'default' })
run('button-destructive', 'button', { w: 120, h: 40 }, { variant: 'destructive', size: 'default' })
run('button-ghost', 'button', { w: 120, h: 40 }, { variant: 'ghost', size: 'default' })
run('button-link', 'button', { w: 96, h: 40 }, { variant: 'link', size: 'default' })
run('button-pill', 'button', { w: 120, h: 40 }, { variant: 'default', size: 'lg', shape: 'pill' })
run('button-disabled', 'button', { w: 120, h: 40 }, { variant: 'default', size: 'default', disabled: true })
run('checkbox', 'checkbox', { w: 20, h: 20 }, {})
run('checkbox-invalid', 'checkbox', { w: 20, h: 20 }, { invalid: true })
run('switch', 'switch', { w: 44, h: 24 }, {})
run('switch-thumb', 'switch-thumb', { w: 20, h: 20 }, {})
run('badge', 'badge', { w: 64, h: 24 }, { variant: 'default', size: 'default' })
run('badge-outline', 'badge', { w: 64, h: 24 }, { variant: 'outline', size: 'default', tally: 3 })
run('tabs', 'tabs', { w: 96, h: 32 }, { variant: 'default', orientation: 'horizontal' })
run('tabs-line', 'tabs', { w: 96, h: 32 }, { variant: 'line', orientation: 'horizontal' })
run('slider-track', 'slider-track', { w: 200, h: 12 }, { ticks: 5 })
run('slider-range', 'slider-range', { w: 120, h: 12 }, {})
run('slider-thumb', 'slider-thumb', { w: 20, h: 20 }, {})
run('stamp-button', 'stamp-button', { w: 120, h: 44 }, { ink: 'red' })
run('separator-tape', 'separator', { w: 240, h: 12 }, { variant: 'tape', orientation: 'horizontal' })
run('separator-torn', 'separator', { w: 240, h: 12 }, { variant: 'torn', orientation: 'horizontal' })
run('separator-stitched', 'separator', { w: 240, h: 12 }, { variant: 'stitched', orientation: 'horizontal' })
run('page-decor', 'page-decor', { w: 320, h: 400 }, { holes: 'start', reinforce: true, stain: true })
run('sticky-note-decor', 'sticky-note-decor', { w: 200, h: 200 }, {})
run('paper-sheet-torn', 'paper-sheet', { w: 240, h: 160 }, { stock: 'paper', edge: { top: 'torn' }, shadow: 'paper' })
run('paper-sheet-sticky', 'paper-sheet', { w: 200, h: 200 }, { stock: 'sticky-yellow', edge: 'cut', shadow: 'sticky' })
run('paper-sheet-kraft', 'paper-sheet', { w: 240, h: 160 }, { stock: 'kraft', edge: 'deckle', shadow: 'card' })
run('paper-rules-hand', 'paper-rules-hand', { w: 240, h: 160 }, { paper: 'ruled' })
run('chart-pie', 'chart-pie', { w: 200, h: 200 }, {
  type: 'pie', inner: 0.5, start: 0, labels: true, patterns: true, state: 'ready',
  slices: [
    { key: 'a', name: 'A', slot: 0, pattern: 'solid', value: 3 },
    { key: 'b', name: 'B', slot: 1, pattern: 'hatch', value: 2 },
    { key: 'c', name: 'C', slot: 2, pattern: 'dots', value: 1 },
  ],
})
run('chart-xy-bar', 'chart-xy', { w: 320, h: 200 }, buildXY({
  rows: [{ m: 'Jan', a: 3, b: 5 }, { m: 'Feb', a: 6, b: 2 }, { m: 'Mar', a: 4, b: 7 }, { m: 'Apr', a: 8, b: 4 }],
  xKey: 'm', kind: 'bar', series: [{ key: 'a' }, { key: 'b' }], patterns: true,
}))
run('chart-xy-line', 'chart-xy', { w: 320, h: 200 }, buildXY({
  rows: [{ m: 'Jan', a: 3 }, { m: 'Feb', a: 6 }, { m: 'Mar', a: 4 }, { m: 'Apr', a: 8 }],
  xKey: 'm', kind: 'area', series: [{ key: 'a' }], notes: [{ at: 'max', text: 'peak' }],
}))

const curated = new Set(frames.map((f) => f.recipe))
for (const recipe of allRecipes()) {
  if (curated.has(recipe.id)) continue
  try {
    run(`auto-${recipe.id}`, recipe.id, { w: 160, h: 48 }, {})
  } catch {
    // recipes that need params beyond {} are skipped
  }
}

const iconDefs = icons as Record<string, ArtDef>
for (const name of ['check', 'heart', 'search', 'settings', 'calendar']) {
  const def = iconDefs[name]
  if (def) art(`icon-${name}`, drawSkeleton(def, 24, name, { tone: 'ui', kind: 'icon' }))
}
const doodleDefs = doodles as Record<string, ArtDef>
for (const name of Object.keys(doodleDefs).slice(0, 4)) art(`doodle-${name}`, drawSkeleton(doodleDefs[name], 96, name, { tone: 'doodle', kind: 'doodle' }))
art('doodle-hi', drawSkeleton(doodleDefs[Object.keys(doodleDefs)[0]], 160, 'hi', { tone: 'doodle', kind: 'doodle' }))
const stickerDefs = stickers as Record<string, StickerDef>
for (const name of Object.keys(stickerDefs).slice(0, 3)) art(`sticker-${name}`, renderSticker(stickerDefs[name], 96, name, { idPrefix: `ll-st-${name}` }))
const peelName = Object.keys(stickerDefs)[3]
art(`sticker-peel-${peelName}`, renderSticker(stickerDefs[peelName], 96, peelName, { peel: true, idPrefix: 'll-peel' }))
const face = stickerFace(Object.keys(stickerDefs)[0], 96, 'face')
if (face) art('sticker-kiss-cut', { svg: kissCut(face, 'll-kc') + face.svg, w: face.w, h: face.h })
for (const variant of ['scallop', 'rosette', 'wax', 'ticket'] as const) {
  art(`seal-${variant}`, sealArt({ variant, text: 'APPROVED', mark: 'check', ribbon: 'red' }, 120, variant))
}

writeFixture('packages/looseleaf_ui/test/fixtures/frames.json', { frames })
