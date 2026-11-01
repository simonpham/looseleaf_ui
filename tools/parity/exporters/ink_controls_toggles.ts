// runRecipe frames of the toggle recipes (checkbox, radio, switch, toggle, toggle group, slider,
// progress), spinnerMark results and the skeleton/item CSS, for
// packages/looseleaf_ink/test/controls_toggles_test.dart.
import { checkboxRecipe } from '@/lib/ink/recipes/checkbox-ink'
import { radioRecipe } from '@/lib/ink/recipes/radio-group-ink'
import { switchRecipe, switchThumbRecipe } from '@/lib/ink/recipes/switch-ink'
import { toggleRecipe } from '@/lib/ink/recipes/toggle-ink'
import { toggleGroupRecipe } from '@/lib/ink/recipes/toggle-group-ink'
import { sliderRangeRecipe, sliderThumbRecipe, sliderTrackRecipe } from '@/lib/ink/recipes/slider-ink'
import { progressFillRecipe, progressRecipe } from '@/lib/ink/recipes/progress-ink'
import { spinnerMark } from '@/lib/ink/recipes/spinner-ink'
import { skeletonCss } from '@/lib/ink/recipes/skeleton-ink'
import { itemCss } from '@/lib/ink/recipes/item-ink'
import type { Recipe } from '@/lib/ink/recipes'
import { RecipeCases } from '../recipe_frames'
import { writeFixture } from '../write'

const cases = new RecipeCases()
const r = (x: unknown): Recipe<never> => x as Recipe<never>
const states = [['rest', {}], ['invalid', { invalid: true }], ['disabled', { disabled: true }], ['invalid disabled', { invalid: true, disabled: true }]] as const

for (const [tag, params] of states) {
  cases.sweep(r(checkboxRecipe), tag, 20, 20, params)
  cases.add(r(checkboxRecipe), `${tag} small`, 14, 14, params)
  cases.add(r(checkboxRecipe), `${tag} large`, 32, 32, params)
  cases.sweep(r(radioRecipe), tag, 20, 20, params)
  cases.add(r(radioRecipe), `${tag} small`, 14, 14, params)
  cases.add(r(radioRecipe), `${tag} large`, 30, 30, params)
  cases.sweep(r(switchRecipe), tag, 44, 24, params)
  cases.add(r(switchRecipe), `${tag} small`, 32, 18, params)
  cases.sweep(r(sliderThumbRecipe), tag, 20, 20, params)
}
cases.add(r(checkboxRecipe), 'calm small invalid', 14, 14, { invalid: true }, { density: 'calm' })
for (const [tag, params] of [['rest', {}], ['disabled', { disabled: true }]] as const) {
  cases.sweep(r(switchThumbRecipe), tag, 20, 20, params)
  cases.add(r(switchThumbRecipe), `${tag} small`, 12, 12, params)
}

for (const variant of ['default', 'outline'] as const) {
  for (const [tag, params] of [
    ['rest', {}],
    ['marker', { tone: 'marker' }],
    ['hi', { tone: 'hi' }],
    ['invalid', { invalid: true }],
    ['disabled', { disabled: true }],
    ['joined', { joined: true }],
    ['joined vertical', { joined: true, vertical: true }],
    ['joined disabled', { joined: true, disabled: true }],
    ['joined invalid', { joined: true, invalid: true, tone: 'marker' }],
  ] as const) {
    cases.sweep(r(toggleRecipe), `${variant} ${tag}`, 40, 36, { variant, ...params })
    cases.add(r(toggleRecipe), `${variant} ${tag} wide`, 400, 40, { variant, ...params })
  }
  cases.add(r(toggleRecipe), `${variant} small`, 24, 24, { variant, tone: 'marker' })
  cases.add(r(toggleRecipe), `${variant} long`, 120, 36, { variant, tone: 'marker' }, { density: 'calm' })
  cases.add(r(toggleRecipe), `${variant} long invalid`, 120, 36, { variant, invalid: true }, { density: 'calm' })
}

for (const [tag, params] of [
  ['loose', { joined: false }],
  ['joined', { joined: true }],
  ['joined invalid', { joined: true, invalid: true }],
  ['joined disabled', { joined: true, disabled: true }],
] as const) {
  cases.sweep(r(toggleGroupRecipe), tag, 160, 36, params)
  cases.add(r(toggleGroupRecipe), `${tag} wide`, 420, 36, params)
}

for (const [tag, params] of [
  ['rest', {}],
  ['ticks', { ticks: 4 }],
  ['invalid', { invalid: true }],
  ['disabled ticks', { disabled: true, ticks: 5 }],
] as const) {
  cases.sweep(r(sliderTrackRecipe), tag, 200, 12, params)
  cases.add(r(sliderTrackRecipe), `${tag} vertical`, 12, 160, { vertical: true, ...params })
  cases.add(r(sliderTrackRecipe), `${tag} long`, 560, 10, params)
}
cases.add(r(sliderTrackRecipe), 'short ticks', 30, 12, { ticks: 2 })
for (const [tag, params] of [['rest', {}], ['hi', { tone: 'hi' }], ['blue', { tone: 'blue' }], ['marker', { tone: 'marker' }], ['disabled', { disabled: true }]] as const) {
  cases.sweep(r(sliderRangeRecipe), tag, 120, 12, params)
  cases.add(r(sliderRangeRecipe), `${tag} vertical`, 12, 90, { vertical: true, ...params })
}

cases.sweep(r(progressRecipe), 'rest', 200, 12, {})
cases.add(r(progressRecipe), 'long', 320, 16, {})
for (const tone of [undefined, 'marker', 'hi', 'green', 'blue'] as const) {
  const p = tone ? { tone } : {}
  cases.sweep(r(progressFillRecipe), `${tone ?? 'none'}`, 120, 12, p)
  cases.sweep(r(progressFillRecipe), `${tone ?? 'none'} indeterminate`, 120, 12, { ...p, indeterminate: true })
  cases.add(r(progressFillRecipe), `${tone ?? 'none'} indeterminate long`, 240, 16, { ...p, indeterminate: true })
}

cases.write('packages/looseleaf_ink/test/fixtures/controls_toggles.json')

const spinners = [
  { seed: 'sp-a', px: 16 },
  { seed: 'sp-b', px: 24 },
  { seed: 'sp-c', px: 48, tier: 'hi' },
  { seed: 'sp-d', px: 24, calm: true },
  { seed: 'sp-e', px: 32, shape: 'loops' },
  { seed: 'sp-f', px: 40, shape: 'loops', w: 90, h: 20 },
  { seed: 'sp-g', px: 18, shape: 'loops', tier: 'hi' },
] as const
writeFixture('packages/looseleaf_ink/test/fixtures/controls_toggles_extra.json', {
  spinners: spinners.map((s) => {
    const { seed, px, ...o } = s
    const res = spinnerMark(seed, px, o as never)
    return { ...s, out: { svg: res.svg, w: res.w, h: res.h, pad: res.pad, layers: res.layers, parts: res.parts } }
  }),
  skeletonCss: skeletonCss(),
  itemCss: itemCss(),
})
