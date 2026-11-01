// runRecipe frames of the surface mark recipes (attachment, bubble, carousel, code block, corkboard, dropzone,
// empty, flip card, peel corner), for packages/looseleaf_ink/test/marks_surfaces_test.dart.
import '@/lib/ink/recipes/attachment-ink'
import '@/lib/ink/recipes/bubble-ink'
import '@/lib/ink/recipes/carousel-ink'
import '@/lib/ink/recipes/code-block-ink'
import '@/lib/ink/recipes/corkboard-ink'
import '@/lib/ink/recipes/dropzone-ink'
import '@/lib/ink/recipes/empty-ink'
import '@/lib/ink/recipes/flip-card-ink'
import '@/lib/ink/recipes/peel-corner-ink'
import { runCases, spread, type RecipeCase } from '../recipe_cases'
import { writeFixture } from '../write'

const cases: RecipeCase[] = []

for (const state of ['idle', 'uploading', 'processing', 'error', 'done']) {
  cases.push(...spread(`attachment ${state}`, 'attachment', 220, 56, { state, orientation: 'horizontal', interactive: true }))
  cases.push({ name: `attachment ${state} vertical`, recipe: 'attachment', w: 120, h: 140, params: { state, orientation: 'vertical' } })
}
cases.push({ name: 'attachment no focus', recipe: 'attachment', w: 200, h: 48, params: { state: 'done', orientation: 'horizontal' }, lazy: [] })
for (const state of ['idle', 'error']) {
  for (const variant of ['icon', 'image']) {
    cases.push(...spread(`attachment-media ${state} ${variant}`, 'attachment-media', 40, 40, { state, variant }))
  }
}
cases.push(...spread('attachment-progress', 'attachment-progress', 160, 8, {}))
cases.push({ name: 'attachment-progress indeterminate', recipe: 'attachment-progress', w: 80, h: 6, params: { indeterminate: true } })

const bubbleVariants = ['default', 'secondary', 'muted', 'tinted', 'outline', 'ghost', 'destructive']
for (const variant of bubbleVariants) {
  cases.push(...spread(`bubble ${variant}`, 'bubble', 200, 48, { variant, tail: 'start', interactive: true }))
  cases.push({ name: `bubble ${variant} small`, recipe: 'bubble', w: 90, h: 26, params: { variant, tail: 'end' } })
  cases.push({ name: `bubble ${variant} you`, recipe: 'bubble', w: 260, h: 80, params: { variant, tail: 'end', pen: 'you' } })
}
cases.push({ name: 'bubble rtl end', recipe: 'bubble', w: 180, h: 40, params: { variant: 'default', tail: 'end' }, dir: 'rtl' })
cases.push(...spread('bubble-reactions', 'bubble-reactions', 80, 24, {}))
cases.push(...spread('bubble-reactions dashed', 'bubble-reactions', 100, 28, { dashed: true }))

for (const slash of [false, true]) {
  cases.push(...spread(`carousel-tick ${slash ? 'slash' : 'plain'}`, 'carousel-tick', 16, 28, { slash, pitch: 14 }))
  cases.push({ name: `carousel-tick ${slash ? 'slash' : 'plain'} tall`, recipe: 'carousel-tick', w: 20, h: 40, params: { slash, pitch: 20 } })
}

cases.push(...spread('code-block-rule', 'code-block-rule', 320, 8, {}))
cases.push({ name: 'code-block-rule narrow', recipe: 'code-block-rule', w: 90, h: 6, params: {} })
cases.push(...spread('code-block-body', 'code-block-body', 320, 160, {}))

cases.push(...spread('corkboard', 'corkboard', 320, 220, {}))
cases.push({ name: 'corkboard frame 18', recipe: 'corkboard', w: 260, h: 180, params: { frame: 18 } })
for (const color of ['tomato', 'sky', 'lemon']) cases.push(...spread(`corkboard-pin ${color}`, 'corkboard-pin', 22, 22, { color }))
cases.push(...spread('corkboard-note', 'corkboard-note', 140, 120, {}))

cases.push(...spread('dropzone', 'dropzone', 320, 160, {}))
cases.push(...spread('dropzone over', 'dropzone', 320, 160, { over: true }))
cases.push(...spread('dropzone invalid', 'dropzone', 240, 120, { invalid: true }))
cases.push(...spread('dropzone disabled', 'dropzone', 240, 120, { disabled: true }))
cases.push({ name: 'dropzone small', recipe: 'dropzone', w: 50, h: 40, params: {} })
cases.push({ name: 'dropzone focus only', recipe: 'dropzone', w: 200, h: 100, params: {}, lazy: ['focus'] })
for (const status of ['idle', 'done', 'error']) cases.push(...spread(`dropzone-item ${status}`, 'dropzone-item', 240, 32, { status }))
cases.push({ name: 'dropzone-item error narrow', recipe: 'dropzone-item', w: 50, h: 28, params: { status: 'error' } })

cases.push(...spread('empty-frame', 'empty-frame', 300, 180, {}))
cases.push({ name: 'empty-frame small', recipe: 'empty-frame', w: 40, h: 30, params: {} })
cases.push(...spread('empty-media', 'empty-media', 56, 56, {}))

cases.push(...spread('flip-card-trigger', 'flip-card-trigger', 220, 140, {}))
cases.push(...spread('flip-card-trigger no hint', 'flip-card-trigger', 220, 140, { hint: false }))

cases.push(...spread('peel-corner-flap', 'peel-corner-flap', 120, 120, {}))
cases.push({ name: 'peel-corner-flap mirror kraft', recipe: 'peel-corner-flap', w: 90, h: 100, params: { back: 'kraft', mirror: true } })
cases.push({ name: 'peel-corner-flap mirror calm', recipe: 'peel-corner-flap', w: 60, h: 60, params: { mirror: false }, density: 'calm' })
cases.push(...spread('peel-corner-trigger', 'peel-corner-trigger', 48, 48, {}))

writeFixture('packages/looseleaf_ink/test/fixtures/marks_surfaces.json', { frames: runCases(cases) })
