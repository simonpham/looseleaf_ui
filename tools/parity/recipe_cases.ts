// Shared case runner for recipe exporters: runs registered recipes by id over a list of cases.
import { DEFAULT_KNOBS, getRecipe, resolveKnobs, runRecipe, stableStringify, type Density, type Dir, type InkLayerName } from '@/lib/ink/recipes'
import type { Knobs } from '@/lib/ink/builder'
import type { Tier } from '@/lib/ink/types'

export interface RecipeCase {
  name: string
  recipe: string
  w: number
  h: number
  params: unknown
  seed?: string
  tier?: Tier
  density?: Density
  dir?: Dir
  knobs?: Knobs
  lazy?: InkLayerName[]
  lazyOnly?: boolean
  pad?: number
}

/** Runs each case; lazy defaults to every lazy layer of the recipe, the seed to the case name. */
export function runCases(cases: RecipeCase[]): unknown[] {
  return cases.map((c) => {
    const recipe = getRecipe(c.recipe)
    if (!recipe) throw new Error(`no recipe ${c.recipe}`)
    const density = c.density ?? 'comfortable'
    const full = {
      name: c.name,
      recipe: c.recipe,
      w: c.w,
      h: c.h,
      params: c.params,
      seed: c.seed ?? c.name,
      tier: c.tier ?? 'lo',
      density,
      dir: c.dir ?? 'ltr',
      knobs: c.knobs ?? resolveKnobs(DEFAULT_KNOBS, density),
      lazy: c.lazy ?? [...recipe.lazy],
      lazyOnly: c.lazyOnly ?? false,
      pad: c.pad,
    }
    const out = runRecipe(recipe as never, {
      box: { w: full.w, h: full.h },
      params: full.params as never,
      seed: full.seed,
      tier: full.tier,
      density: full.density,
      dir: full.dir,
      knobs: full.knobs,
      lazy: full.lazy,
      lazyOnly: full.lazyOnly,
      pad: full.pad,
    })
    return { ...full, key: stableStringify(c.params), out }
  })
}

/** The standard spread for one recipe and params: base, rtl, calm, compact, hi tier, lazy only. */
export function spread(name: string, recipe: string, w: number, h: number, params: unknown): RecipeCase[] {
  return [
    { name, recipe, w, h, params },
    { name: `${name} rtl`, recipe, w, h, params, dir: 'rtl' },
    { name: `${name} calm`, recipe, w, h, params, density: 'calm' },
    { name: `${name} compact`, recipe, w, h, params, density: 'compact' },
    { name: `${name} hi`, recipe, w, h, params, tier: 'hi' },
    { name: `${name} lazy only`, recipe, w, h, params, lazyOnly: true },
  ]
}
