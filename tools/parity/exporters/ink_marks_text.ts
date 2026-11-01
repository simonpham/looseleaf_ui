// runRecipe frames of the text-mark recipes (underline, strike, scribble, highlight, tally, arrow, bracket, circled,
// quote, signature, squiggle, margin-bracket, marker-rule) and the helpers they share, for
// packages/looseleaf_ink/test/marks_text_test.dart.
import '@/lib/ink/recipes/underline-ink'
import '@/lib/ink/recipes/strike-ink'
import '@/lib/ink/recipes/scribble-ink'
import '@/lib/ink/recipes/highlight-ink'
import '@/lib/ink/recipes/arrow-ink'
import '@/lib/ink/recipes/bracket-ink'
import '@/lib/ink/recipes/quote-ink'
import '@/lib/ink/recipes/signature-ink'
import '@/lib/ink/recipes/squiggle-ink'
import '@/lib/ink/recipes/margin-bracket-ink'
import '@/lib/ink/recipes/marker-ink'
import { tallyBox } from '@/lib/ink/recipes/tally-ink'
import { bleedOf, circledReach, loopRadii } from '@/lib/ink/recipes/circled-ink'
import { arrowReach } from '@/lib/ink/recipes/arrow-ink'
import { boilKnobs, boilSeed } from '@/lib/ink/recipes/boil-ink'
import { lineMetrics, markPen, overshoot, type MarkPen, type MarkWeight } from '@/lib/ink/recipes/text-marks-ink'
import { runCases, spread, type RecipeCase } from '../recipe_cases'
import { writeFixture } from '../write'

const line = (h: number, fs: number, first = true, last = true, extra: Record<string, unknown> = {}) => ({ ...lineMetrics(h, fs), first, last, n: 1, ...extra })
const tones: MarkPen[] = ['ink', 'blue', 'red', 'green', 'pencil', 'marker', 'orange']
const weights: MarkWeight[] = ['fine', 'regular', 'brush']

const cases: RecipeCase[] = []
for (const kind of ['single', 'double', 'wavy', 'scribble']) {
  cases.push(...spread(`underline ${kind}`, 'underline', 120, 24, { ...line(24, 16), kind, tone: 'ink', weight: 'regular' }))
}
for (const tone of tones.slice(1)) {
  for (const weight of weights) {
    cases.push({ name: `underline ${tone} ${weight}`, recipe: 'underline', w: 90, h: 30, params: { ...line(30, 20, false, true), kind: 'single', tone, weight } })
  }
}
cases.push({ name: 'underline small font', recipe: 'underline', w: 60, h: 18, params: { ...line(18, 12, true, false), kind: 'scribble', tone: 'red', weight: 'regular' } })

for (const kind of ['single', 'double', 'cross']) {
  cases.push(...spread(`strike ${kind}`, 'strike', 110, 24, { ...line(24, 16), kind, tone: 'red', weight: 'regular' }))
  cases.push({ name: `strike ${kind} green fine wide`, recipe: 'strike', w: 300, h: 30, params: { ...line(30, 20), kind, tone: 'green', weight: 'fine' } })
}
cases.push({ name: 'strike ink brush', recipe: 'strike', w: 80, h: 24, params: { ...line(24, 16, false, false), kind: 'single', tone: 'ink', weight: 'brush' } })

for (const weight of weights) {
  cases.push(...spread(`scribble ${weight}`, 'scribble', 140, 24, { ...line(24, 16), tone: 'ink', weight }))
}
cases.push({ name: 'scribble long', recipe: 'scribble', w: 420, h: 30, params: { ...line(30, 20), tone: 'blue', weight: 'regular' } })

for (const tone of ['yellow', 'pink', 'green', 'blue', 'orange', 'lilac', 'teal']) {
  cases.push({ name: `highlight ${tone}`, recipe: 'highlight', w: 70, h: 24, params: { ...line(24, 16), tone } })
}
cases.push(...spread('highlight long', 'highlight', 160, 24, { ...line(24, 16), tone: 'yellow' }))
cases.push({ name: 'highlight under fat', recipe: 'highlight', w: 120, h: 24, params: { ...line(24, 16, false, true), tone: 'pink', cover: 'under', fat: 0.6 } })
cases.push({ name: 'highlight full mid', recipe: 'highlight', w: 120, h: 24, params: { ...line(24, 16, false, false), tone: 'green', cover: 'full', fat: 1.4 } })

for (const count of [1, 4, 5, 7, 12]) {
  const box = tallyBox(count, 18)
  cases.push({ name: `tally ${count}`, recipe: 'tally', w: box.w, h: box.h, params: { count, gh: 18, tone: 'ink', weight: 'regular' } })
}
cases.push(...spread('tally rtl', 'tally', tallyBox(8, 22).w, tallyBox(8, 22).h, { count: 8, gh: 22, tone: 'red', weight: 'fine' }))
cases.push({ name: 'tally forced ltr', recipe: 'tally', w: 60, h: 22, params: { count: 6, gh: 18, tone: 'blue', weight: 'brush', rtl: false }, dir: 'rtl' })
cases.push({ name: 'tally forced rtl', recipe: 'tally', w: 60, h: 22, params: { count: 6, gh: 18, tone: 'blue', weight: 'brush', rtl: true } })
cases.push({ name: 'tally zero', recipe: 'tally', w: 10, h: 22, params: { count: 0, gh: 18, tone: 'ink', weight: 'regular' } })

const arrow = (extra: Record<string, unknown>) => ({ direction: 'right', curve: 'curved', head: 'v', tone: 'ink', weight: 'regular', bend: 'up', mirror: false, ...extra })
for (const direction of ['right', 'left', 'up', 'down', 'up-right', 'up-left', 'down-right', 'down-left']) {
  cases.push({ name: `arrow ${direction}`, recipe: 'arrow', w: 80, h: 48, params: arrow({ direction }) })
}
for (const curve of ['straight', 'curved', 'curl']) {
  for (const head of ['v', 'two', 'open', 'solid', 'none']) {
    cases.push({ name: `arrow ${curve} ${head}`, recipe: 'arrow', w: 96, h: 40, params: arrow({ curve, head, bend: 'down' }) })
  }
}
cases.push(...spread('arrow mirror', 'arrow', 90, 40, arrow({ mirror: true, direction: 'up-right', weight: 'brush', tone: 'red' })))
cases.push({ name: 'arrow aimed', recipe: 'arrow', w: 20, h: 20, params: arrow({ dx: 60, dy: -25, tone: 'blue', weight: 'fine' }) })
cases.push({ name: 'arrow aimed animate', recipe: 'arrow', w: 20, h: 20, params: arrow({ dx: -40, dy: 30, animate: true }) })
cases.push({ name: 'arrow animate', recipe: 'arrow', w: 90, h: 40, params: arrow({ animate: true, tone: 'marker' }) })
cases.push({ name: 'arrow vertical straight', recipe: 'arrow', w: 30, h: 90, params: arrow({ direction: 'down', curve: 'straight' }) })

for (const kind of ['square', 'curly', 'round']) {
  for (const side of ['start', 'end']) {
    cases.push(...spread(`bracket ${kind} ${side}`, 'bracket', 40, 120, { kind, side, tone: 'blue', weight: 'regular', inset: 6 }))
  }
}
cases.push({ name: 'bracket animate', recipe: 'bracket', w: 40, h: 60, params: { kind: 'curly', side: 'start', tone: 'red', weight: 'brush', inset: 4, animate: true } })

for (const shape of ['circle', 'box', 'brackets']) {
  cases.push(...spread(`circled ${shape}`, 'circled', 80, 24, { ...line(24, 16), shape, tone: 'red', weight: 'regular' }))
  cases.push({ name: `circled ${shape} tall`, recipe: 'circled', w: 160, h: 70, params: { ...line(24, 16), shape, tone: 'blue', weight: 'fine', bleed: 6.3 } })
  cases.push({ name: `circled ${shape} animate`, recipe: 'circled', w: 80, h: 24, params: { ...line(24, 16, true, true, { animate: true }), shape, tone: 'ink', weight: 'brush', bleed: 0 } })
}
cases.push({ name: 'circled huge bleed', recipe: 'circled', w: 80, h: 24, params: { ...line(24, 16), shape: 'circle', tone: 'green', weight: 'regular', bleed: 40 } })

for (const tone of ['ink', 'marker', 'blue']) {
  for (const weight of weights) {
    cases.push({ name: `quote ${tone} ${weight}`, recipe: 'quote', w: 260, h: 120, params: { tone, weight, size: 30, rule: false } })
  }
}
cases.push(...spread('quote rule', 'quote', 240, 140, { tone: 'red', weight: 'regular', size: 36, rule: true }))
cases.push({ name: 'quote animate', recipe: 'quote', w: 240, h: 100, params: { tone: 'ink', weight: 'regular', size: 24, rule: true, animate: true } })

for (const flourish of ['swoosh', 'underline', 'none']) {
  cases.push(...spread(`signature ${flourish}`, 'signature', 180, 60, { flourish, tone: 'blue', weight: 'regular', fs: 36 }))
}
cases.push({ name: 'signature animate', recipe: 'signature', w: 200, h: 50, params: { flourish: 'swoosh', tone: 'ink', weight: 'brush', fs: 28, animate: true } })
cases.push({ name: 'signature small', recipe: 'signature', w: 120, h: 16, params: { flourish: 'underline', tone: 'red', weight: 'fine', fs: 20 } })

for (const kind of ['wavy', 'zigzag', 'loops', 'scallops', 'dashes', 'dots']) {
  cases.push(...spread(`squiggle ${kind}`, 'squiggle', 200, 16, { kind, orientation: 'horizontal', tone: 'ink', weight: 'regular' }))
  cases.push({ name: `squiggle ${kind} vertical`, recipe: 'squiggle', w: 14, h: 160, params: { kind, orientation: 'vertical', tone: 'blue', weight: 'brush' } })
  cases.push({ name: `squiggle ${kind} long`, recipe: 'squiggle', w: 320, h: 24, params: { kind, orientation: 'horizontal', tone: 'red', weight: 'fine' } })
}
cases.push({ name: 'squiggle animate', recipe: 'squiggle', w: 200, h: 16, params: { kind: 'wavy', orientation: 'horizontal', tone: 'ink', weight: 'regular', animate: true } })
cases.push({ name: 'squiggle animate vertical', recipe: 'squiggle', w: 16, h: 120, params: { kind: 'zigzag', orientation: 'vertical', tone: 'ink', weight: 'regular', animate: true } })

for (const kind of ['square', 'curly']) {
  cases.push(...spread(`margin-bracket ${kind}`, 'margin-bracket', 16, 90, { kind }))
}
cases.push({ name: 'margin-bracket short', recipe: 'margin-bracket', w: 30, h: 6, params: { kind: 'square' } })

for (const side of ['start', 'end', 'full']) {
  for (const tone of ['default', 'new']) {
    cases.push(...spread(`marker-rule ${side} ${tone}`, 'marker-rule', 120, 10, { side, tone }))
  }
}
cases.push({ name: 'marker-rule wavy full', recipe: 'marker-rule', w: 160, h: 12, params: { side: 'full', tone: 'new', style: 'wavy' } })
cases.push({ name: 'marker-rule wavy start', recipe: 'marker-rule', w: 160, h: 12, params: { side: 'start', tone: 'default', style: 'wavy' } })
cases.push({ name: 'marker-rule line', recipe: 'marker-rule', w: 160, h: 12, params: { side: 'full', tone: 'default', style: 'line' } })

const helpers = {
  lineMetrics: [[24, 16], [18.6, 11.2], [40, 3]].map(([h, fs]) => ({ h, fs, out: lineMetrics(h, fs) }))
    .concat([{ h: 30, fs: 20, r: { asc: 0, desc: 0, xh: 0.5, cap: 0.7, pdesc: 0.2 }, out: lineMetrics(30, 20, { asc: 0, desc: 0, xh: 0.5, cap: 0.7, pdesc: 0.2 }) } as never]),
  markPen: tones.flatMap((tone) => weights.flatMap((weight) => [10, 18, 40].flatMap((fs) => [false, true].map((pencil) => ({ tone, weight, fs, pencil, out: markPen(tone, weight, fs, { pencil }) }))))),
  overshoot: [4, 16, 30].map((fs) => ({ fs, out: overshoot(fs) })),
  tallyBox: [0, 1, 5, 6, 10, 13, 120].map((count) => ({ count, gh: 18, out: tallyBox(count, 18) })),
  arrowReach: [{}, { dx: 3 }, { dx: 30, dy: -40.5 }].map((p) => ({ p, out: arrowReach(p) })),
  bleedOf: [undefined, 0, 3.3, -2, 99, NaN].map((bleed) => ({ bleed: bleed === undefined ? '__undefined' : Number.isNaN(bleed) ? '__NaN' : bleed, out: bleedOf({ bleed }) })),
  circledReach: [[80, 24, 16, undefined], [200, 90, 20, 9]].map(([w, h, fs, bleed]) => ({ w, h, fs, bleed: bleed ?? null, out: circledReach(w as number, h as number, { fs: fs as number, bleed }) })),
  loopRadii: [[40, 10, 16, 24, undefined, 24], [80, 30, 16, 24, 5, 70]].map(([tw, th, fs, ch, bleed, h]) => ({ tw, th, fs, ch, bleed: bleed ?? null, h, out: loopRadii(tw as number, th as number, { fs: fs as number, ch: ch as number, bleed }, h as number) })),
  boilKnobs: [0, 1, 2, 3, 5, -1].flatMap((frame) => [1, 0.5, 2, -1].map((strength) => ({ frame, strength, out: boilKnobs(frame, strength) }))),
  boilSeed: [['abc', 0], ['abc', 2], [42, 0], [42, 3]].map(([seed, frame]) => ({ seed, frame, out: boilSeed(seed, frame as number) })),
}

writeFixture('packages/looseleaf_ink/test/fixtures/marks_text.json', { frames: runCases(cases), helpers })
