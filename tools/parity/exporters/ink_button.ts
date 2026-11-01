// Recipe framework helpers and runRecipe(buttonRecipe, ...) frames, for packages/looseleaf_ink/test/recipes_test.dart
// and button_test.dart.
import { DEFAULT_KNOBS, bucketBox, knobsKey, orderLayers, resolveKnobs, runRecipe, stableStringify, type Density, type InkLayerName } from '@/lib/ink/recipes'
import { buttonRecipe, type ButtonParams } from '@/lib/ink/recipes/button-ink'
import type { Knobs } from '@/lib/ink/builder'
import type { Tier } from '@/lib/ink/types'
import { writeFixture } from '../write'

const framework = {
  order: [
    ['focus', 'rest', 'hover'],
    ['pressed', 'busy', 'checked', 'disabled', 'rest', 'open', 'invalid', 'indeterminate', 'focus', 'hover'],
    [],
  ].map((names) => ({ names, out: orderLayers(names as InkLayerName[]) })),
  stringify: [
    null, true, false, 'a"b\\c\n\t\u0001é', 0, -0, 1.5, 1e21, 1e-7, 123456789.125, NaN, Infinity,
    [1, 'x', null, undefined, [true]],
    { b: 1, a: 'x', c: undefined, d: null, nested: { z: [1, { y: 2, x: 1 }], A: 0 } },
    { variant: 'default', size: 'sm', disabled: true },
  ].map((v) => ({ v: v === undefined ? '__undefined' : Number.isNaN(v) ? '__NaN' : v === Infinity ? '__Infinity' : v, out: stableStringify(v) })),
  buckets: [[37, 23], [1, 1], [100.4, 35.2], [2, 0.9], [361, 44]].map(([w, h]) => ({ w, h, out: bucketBox(w, h) }))
    .concat([{ w: 37, h: 23, q: [8, 8], out: bucketBox(37, 23, [8, 8]) } as never]),
  knobsKeys: [DEFAULT_KNOBS, { wobble: 0.333, misreg: 1.005, bleed: 2, width: 0.1 + 0.2 }].map((k) => ({ k, out: knobsKey(k) })),
  resolved: (['comfortable', 'compact', 'calm'] as Density[]).map((density) => ({ density, out: resolveKnobs({ wobble: 1.2, misreg: 0.8, bleed: 1.4, width: 1.1 }, density) })),
}

interface Case {
  name: string
  w: number
  h: number
  params: ButtonParams
  seed: string
  tier: Tier
  density: Density
  knobs: Knobs
  lazy?: InkLayerName[]
  lazyOnly?: boolean
  pad?: number
}

const variants = ['default', 'destructive', 'outline', 'secondary', 'ghost', 'link'] as const
const boxes = [
  { tag: 'default', w: 96, h: 36, size: 'default', shape: undefined },
  { tag: 'xs', w: 60, h: 24, size: 'xs', shape: undefined },
  { tag: 'icon', w: 36, h: 36, size: 'icon', shape: undefined },
  { tag: 'pill', w: 120, h: 36, size: 'sm', shape: 'pill' },
  { tag: 'pill-icon', w: 36, h: 36, size: 'icon-sm', shape: 'pill' },
  { tag: 'wide', w: 400, h: 44, size: 'lg', shape: undefined },
] as const

const cases: Case[] = []
const lazy: InkLayerName[] = ['focus', 'pressed']
const base = { tier: 'lo' as Tier, density: 'comfortable' as Density, knobs: DEFAULT_KNOBS, lazy }
for (const variant of variants) {
  for (const b of boxes) {
    const params: ButtonParams = { variant, size: b.size, ...(b.shape ? { shape: b.shape } : {}) }
    cases.push({ ...base, name: `${variant} ${b.tag}`, w: b.w, h: b.h, params, seed: `btn-${variant}-${b.tag}` })
  }
  for (const b of [boxes[0], boxes[2]]) {
    cases.push({ ...base, name: `${variant} ${b.tag} disabled`, w: b.w, h: b.h, params: { variant, size: b.size, disabled: true }, seed: `btn-${variant}-dis` })
  }
  for (const density of ['compact', 'calm'] as Density[]) {
    cases.push({ ...base, name: `${variant} ${density}`, w: 104, h: 32, params: { variant, size: 'sm' }, seed: `btn-${variant}-${density}`, density, knobs: resolveKnobs(DEFAULT_KNOBS, density) })
  }
  cases.push({ ...base, name: `${variant} hi`, w: 96, h: 36, params: { variant, size: 'default' }, seed: `btn-${variant}-hi`, tier: 'hi' })
}
cases.push({ ...base, name: 'lazy only', w: 96, h: 36, params: { variant: 'default', size: 'default' }, seed: 'btn-lazy-only', lazyOnly: true })
cases.push({ ...base, name: 'lazy only disabled', w: 96, h: 36, params: { variant: 'outline', size: 'default', disabled: true }, seed: 'btn-lazy-only', lazyOnly: true })
cases.push({ ...base, name: 'focus only', w: 96, h: 36, params: { variant: 'ghost', size: 'default' }, seed: 'btn-focus', lazy: ['focus'] })
cases.push({ ...base, name: 'no lazy', w: 96, h: 36, params: { variant: 'secondary', size: 'default' }, seed: 'btn-eager', lazy: [] })
cases.push({ ...base, name: 'pad override', w: 96, h: 36, params: { variant: 'destructive', size: 'default' }, seed: 'btn-pad', pad: 5 })
cases.push({ ...base, name: 'theme knobs', w: 96, h: 36, params: { variant: 'default', size: 'default' }, seed: 'btn-knobs', knobs: { wobble: 1.6, misreg: 2, bleed: 1.4, width: 1.2 } })

const frames = cases.map((c) => {
  const f = runRecipe(buttonRecipe, { box: { w: c.w, h: c.h }, params: c.params, seed: c.seed, tier: c.tier, density: c.density, dir: 'ltr', knobs: c.knobs, lazy: c.lazy, lazyOnly: c.lazyOnly, pad: c.pad })
  return { ...c, key: stableStringify(c.params), out: f }
})

writeFixture('packages/looseleaf_ink/test/fixtures/recipes.json', framework)
writeFixture('packages/looseleaf_ink/test/fixtures/button.json', { frames })
