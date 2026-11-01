// runRecipe frames of the text-mark recipes (underline, strike, scribble, highlight, tally, arrow, bracket,
// circled, quote, signature, squiggle, margin-bracket, marker rule), for packages/looseleaf_ink/test/marks_text_test.dart.
import '@/lib/ink/recipes/underline-ink'
import { lineMetrics } from '@/lib/ink/recipes/text-marks-ink'
import { runCases, spread, type RecipeCase } from '../recipe_cases'
import { writeFixture } from '../write'

const line = (h: number, fs: number, first = true, last = true, extra: Record<string, unknown> = {}) => ({ ...lineMetrics(h, fs), first, last, n: 1, ...extra })

const cases: RecipeCase[] = []
for (const kind of ['single', 'double', 'wavy', 'scribble']) {
  cases.push(...spread(`underline ${kind}`, 'underline', 120, 24, { ...line(24, 16), kind, tone: 'ink', weight: 'regular' }))
}
for (const tone of ['blue', 'red', 'green', 'pencil', 'marker', 'orange']) {
  for (const weight of ['fine', 'regular', 'brush']) {
    cases.push({ name: `underline ${tone} ${weight}`, recipe: 'underline', w: 90, h: 30, params: { ...line(30, 20, false, true), kind: 'single', tone, weight } })
  }
}
cases.push({ name: 'underline small font', recipe: 'underline', w: 60, h: 18, params: { ...line(18, 12, true, false), kind: 'scribble', tone: 'red', weight: 'regular' } })

writeFixture('packages/looseleaf_ink/test/fixtures/marks_text.json', { frames: runCases(cases) })
