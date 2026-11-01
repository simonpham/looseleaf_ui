// Shared case builder for recipe exporters: runs runRecipe over a list of cases and writes
// { frames: [...] } with the inputs, the stable params key and the RawFrame of each case.
import { DEFAULT_KNOBS, resolveKnobs, runRecipe, stableStringify, type Density, type InkLayerName, type Recipe } from '@/lib/ink/recipes'
import type { Knobs } from '@/lib/ink/builder'
import type { Tier } from '@/lib/ink/types'
import { writeFixture } from './write'

export interface RecipeCase {
  name: string
  recipe: string
  w: number
  h: number
  params: unknown
  seed: string
  tier: Tier
  density: Density
  knobs: Knobs
  dir: 'ltr' | 'rtl'
  lazy: InkLayerName[]
  lazyOnly?: boolean
  pad?: number
}

export type CaseExtra = Partial<Omit<RecipeCase, 'name' | 'recipe' | 'w' | 'h' | 'params' | 'seed'>>

export class RecipeCases {
  private readonly cases: { recipe: Recipe<never>; c: RecipeCase }[] = []

  /** One case: lo tier, comfortable, default knobs, ltr, every lazy layer. */
  add(recipe: Recipe<never>, name: string, w: number, h: number, params: unknown, extra: CaseExtra = {}): void {
    const c: RecipeCase = {
      name: `${recipe.id} ${name}`, recipe: recipe.id, w, h, params, seed: `${recipe.id}-${name}`,
      tier: 'lo', density: 'comfortable', knobs: DEFAULT_KNOBS, dir: 'ltr', lazy: [...recipe.lazy], ...extra,
    }
    if (extra.density && !extra.knobs) c.knobs = resolveKnobs(DEFAULT_KNOBS, extra.density)
    this.cases.push({ recipe, c })
  }

  /** The base case plus compact, calm, hi tier, rtl and lazy-only variations. */
  sweep(recipe: Recipe<never>, name: string, w: number, h: number, params: unknown): void {
    this.add(recipe, name, w, h, params)
    this.add(recipe, `${name} compact`, w, h, params, { density: 'compact' })
    this.add(recipe, `${name} calm`, w, h, params, { density: 'calm' })
    this.add(recipe, `${name} hi`, w, h, params, { tier: 'hi' })
    this.add(recipe, `${name} rtl`, w, h, params, { dir: 'rtl' })
    if (recipe.lazy.length) this.add(recipe, `${name} lazy only`, w, h, params, { lazyOnly: true })
  }

  write(relativePath: string): void {
    const frames = this.cases.map(({ recipe, c }) => {
      const out = runRecipe(recipe, {
        box: { w: c.w, h: c.h }, params: c.params as never, seed: c.seed, tier: c.tier, density: c.density,
        dir: c.dir, knobs: c.knobs, lazy: c.lazy, lazyOnly: c.lazyOnly, pad: c.pad,
      })
      return { ...c, key: stableStringify(c.params), out }
    })
    writeFixture(relativePath, { frames })
  }
}
