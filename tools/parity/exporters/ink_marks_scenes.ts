// runRecipe frames of the scene recipes (polaroid photo, rating, receipt circle, reveal nib, ribbon, stamp button),
// plus confetti pieces and flights, barcodes and crescents, for packages/looseleaf_ink/test/marks_scenes_test.dart.
import { CONFETTI_COLORS, CONFETTI_KINDS, confettiPiece, simulate } from '@/lib/ink/recipes/confetti-ink'
import { crescent } from '@/lib/ink/recipes/polaroid-ink'
import '@/lib/ink/recipes/rating-ink'
import { barcode } from '@/lib/ink/recipes/receipt-ink'
import '@/lib/ink/recipes/reveal-nib-ink'
import '@/lib/ink/recipes/ribbon-ink'
import '@/lib/ink/recipes/stamp-button-ink'
import { runCases, spread, type RecipeCase } from '../recipe_cases'
import { writeFixture } from '../write'

const cases: RecipeCase[] = []
for (const scene of ['hills', 'sea', 'house', 'night']) {
  cases.push({ name: `polaroid ${scene}`, recipe: 'polaroid-photo', w: 200, h: 160, params: { scene } })
  cases.push({ name: `polaroid ${scene} small`, recipe: 'polaroid-photo', w: 96, h: 80, params: { scene } })
  cases.push({ name: `polaroid ${scene} hi`, recipe: 'polaroid-photo', w: 200, h: 160, params: { scene }, tier: 'hi' })
  cases.push({ name: `polaroid ${scene} calm`, recipe: 'polaroid-photo', w: 200, h: 160, params: { scene }, density: 'calm' })
}
for (const icon of [undefined, 'star', 'heart', 'sun']) {
  const base = icon ? { icon } : {}
  cases.push(...spread(`rating ${icon ?? 'none'}`, 'rating', 28, 28, base))
  cases.push({ name: `rating ${icon} small`, recipe: 'rating', w: 18, h: 18, params: base })
  cases.push({ name: `rating ${icon} big`, recipe: 'rating', w: 48, h: 44, params: base })
  cases.push({ name: `rating ${icon} disabled`, recipe: 'rating', w: 28, h: 28, params: { ...base, disabled: true } })
  cases.push({ name: `rating ${icon} invalid`, recipe: 'rating', w: 28, h: 28, params: { ...base, invalid: true } })
  cases.push({ name: `rating ${icon} invalid rtl`, recipe: 'rating', w: 28, h: 28, params: { ...base, invalid: true }, dir: 'rtl' })
  cases.push({ name: `rating ${icon} disabled invalid`, recipe: 'rating', w: 28, h: 28, params: { ...base, disabled: true, invalid: true } })
}
cases.push({ name: 'rating no lazy', recipe: 'rating', w: 28, h: 28, params: {}, lazy: [] })
for (const pen of ['redfelt', 'blue', 'ink']) {
  cases.push(...spread(`receipt ${pen}`, 'receipt-circle', 60, 18, { pen }))
}
cases.push({ name: 'receipt tall', recipe: 'receipt-circle', w: 40, h: 30, params: { pen: 'ink' } })
cases.push(...spread('reveal nib', 'reveal-nib', 24, 24, {}))
cases.push({ name: 'reveal nib grass big', recipe: 'reveal-nib', w: 48, h: 40, params: { color: 'grass' } })
const ribbonBoxes: Record<string, [number, number]> = { sm: [140, 32], default: [180, 43], lg: [240, 58] }
for (const variant of ['banner', 'swallow', 'flag']) {
  for (const size of ['sm', 'default', 'lg']) {
    const [w, h0] = ribbonBoxes[size]
    const h = variant === 'banner' ? h0 : h0 - (size === 'sm' ? 6 : size === 'default' ? 9 : 12)
    cases.push({ name: `ribbon ${variant} ${size}`, recipe: 'ribbon', w, h, params: { variant, tone: 'marker', size, hoverable: true } })
  }
  cases.push(...spread(`ribbon ${variant}`, 'ribbon', 180, variant === 'banner' ? 43 : 34, { variant, tone: 'hi', size: 'default' }))
  cases.push({ name: `ribbon ${variant} hover rtl`, recipe: 'ribbon', w: 180, h: 43, params: { variant, tone: 'teal', size: 'default', hoverable: true }, dir: 'rtl' })
  cases.push({ name: `ribbon ${variant} narrow`, recipe: 'ribbon', w: 60, h: 34, params: { variant, tone: 'paper', size: 'sm', hoverable: true } })
}
for (const tone of ['tangerine', 'lemon', 'grass', 'sky', 'bubblegum']) {
  cases.push({ name: `ribbon tone ${tone}`, recipe: 'ribbon', w: 160, h: 34, params: { variant: 'flag', tone, size: 'default' } })
}
for (const ink of ['red', 'ink-you', 'green', 'ink']) {
  cases.push(...spread(`stamp ${ink}`, 'stamp-button', 120, 74, { ink }))
  cases.push({ name: `stamp ${ink} disabled`, recipe: 'stamp-button', w: 120, h: 74, params: { ink, disabled: true } })
}
cases.push({ name: 'stamp disabled lazy only', recipe: 'stamp-button', w: 120, h: 74, params: { ink: 'red', disabled: true }, lazyOnly: true })
cases.push({ name: 'stamp wide', recipe: 'stamp-button', w: 200, h: 90, params: { ink: 'green' } })
cases.push({ name: 'stamp focus only', recipe: 'stamp-button', w: 120, h: 74, params: { ink: 'red' }, lazy: ['focus'] })

const pieces = []
for (const kind of CONFETTI_KINDS) {
  for (const [color, variant] of [['tomato', 0], ['sky', 1], ['lemon', 2]] as const) {
    pieces.push({ kind, color, variant, out: confettiPiece(kind, color, variant) })
  }
}
pieces.push({ kind: 'curl', color: 'grape', variant: 5, out: confettiPiece('curl', 'grape', 5) })

const flightOpts = [
  { count: 6, spread: 70, angle: 90, velocity: 520, gravity: 900, drift: 0, duration: 1600, seed: 7 },
  { count: 4, spread: 140, angle: 60, velocity: 380, gravity: 640, drift: 40, duration: 900, seed: 1234.5 },
]
const flights = flightOpts.map((o) => ({ o, out: simulate(o) }))
flights.push({ o: { ...flightOpts[0], seed: 3 }, kinds: ['star', 'dot'], colors: ['teal', 'grape'], out: simulate({ ...flightOpts[0], seed: 3 }, ['star', 'dot'], ['teal', 'grape']) } as never)

const barcodes = [['4006381333931', 180, 40], ['A-12 b', 120, 30], ['', 60, 20], ['ORDER', 90, 24]].map(([v, w, h]) => ({ value: v, w, h, out: barcode(v as string, w as number, h as number) }))
const crescents = [[50, 40, 20, 10, -6, 17.6, 14], [10, 10, 5, -3, 2, 4, 8]].map((a) => ({ args: a, out: crescent(...(a as [number, number, number, number, number, number, number])) }))

writeFixture('packages/looseleaf_ink/test/fixtures/marks_scenes.json', { frames: runCases(cases), pieces, flights, barcodes, crescents, colors: CONFETTI_COLORS })
