// runRecipe frames of the field recipes (input, textarea, select family, combobox), for
// packages/looseleaf_ink/test/controls_fields_test.dart.
import { inputRecipe } from '@/lib/ink/recipes/input-ink'
import { textareaRecipe } from '@/lib/ink/recipes/textarea-ink'
import { selectRecipe } from '@/lib/ink/recipes/select-ink'
import { nativeSelectRecipe } from '@/lib/ink/recipes/native-select-ink'
import { datePickerRecipe } from '@/lib/ink/recipes/date-picker-ink'
import { chipToneList, comboboxChipRecipe, comboboxChipsRecipe, comboboxTriggerRecipe } from '@/lib/ink/recipes/combobox-ink'
import { fieldChoiceRecipe } from '@/lib/ink/recipes/field-ink'
import { fieldErrorRecipe } from '@/lib/ink/recipes/field-error-ink'
import { inputGroupRecipe, inputGroupRuleRecipe } from '@/lib/ink/recipes/input-group-ink'
import { otpCss, otpSlotRecipe } from '@/lib/ink/recipes/input-otp-ink'
import { promptInputBodyRecipe } from '@/lib/ink/recipes/prompt-input-ink'
import { Ink } from '@/lib/ink/builder'
import { seg } from '@/lib/ink/geom'
import type { Recipe } from '@/lib/ink/recipes'
import { writeFixture } from '../write'
import { RecipeCases } from '../recipe_frames'

const cases = new RecipeCases()
const r = (x: unknown): Recipe<never> => x as Recipe<never>

for (const [tag, params] of [['rest', {}], ['invalid', { invalid: true }], ['disabled', { disabled: true }], ['read-only', { readOnly: true }], ['invalid disabled', { invalid: true, disabled: true }]] as const) {
  cases.sweep(r(inputRecipe), tag, 240, 36, params)
}
cases.add(r(inputRecipe), 'narrow invalid', 60, 32, { invalid: true })
cases.add(r(inputRecipe), 'wide', 420, 40, {})

for (const [tag, params] of [
  ['rest', {}],
  ['ruled', { ruled: true }],
  ['ruled grip', { ruled: true, grip: true, lineHeight: 24, ruleTop: 4 }],
  ['ruled invalid grip', { ruled: true, invalid: true, grip: true }],
  ['ruled disabled grip', { ruled: true, disabled: true, grip: true }],
  ['ruled read-only', { ruled: true, readOnly: true }],
] as const) {
  cases.sweep(r(textareaRecipe), tag, 280, 120, params)
}

for (const recipe of [selectRecipe, nativeSelectRecipe, datePickerRecipe, comboboxTriggerRecipe]) {
  for (const [tag, params] of [['rest', {}], ['invalid', { invalid: true }], ['disabled', { disabled: true }]] as const) {
    cases.sweep(r(recipe), tag, 200, 36, params)
  }
  cases.add(r(recipe), 'narrow', 64, 32, {})
  cases.add(r(recipe), 'narrow invalid', 64, 32, { invalid: true })
}
cases.sweep(r(datePickerRecipe), 'cell', 220, 40, { cell: 40 })
cases.add(r(comboboxTriggerRecipe), 'cell invalid rtl', 220, 40, { cell: 28, invalid: true }, { dir: 'rtl' })

for (const [tag, params] of [['rest', {}], ['invalid', { invalid: true }], ['disabled', { disabled: true }]] as const) {
  cases.sweep(r(comboboxChipsRecipe), tag, 260, 36, params)
  cases.sweep(r(comboboxChipsRecipe), `${tag} tall`, 260, 72, params)
}

for (const tone of chipToneList) {
  cases.sweep(r(comboboxChipRecipe), tone, 72, 24, { tone })
}
cases.sweep(r(comboboxChipRecipe), 'disabled', 72, 24, { tone: 'sky', disabled: true })
cases.add(r(comboboxChipRecipe), 'tall', 110, 32, { tone: 'grass' })

cases.sweep(r(fieldChoiceRecipe), 'card', 280, 64, {})
cases.sweep(r(fieldChoiceRecipe), 'wide', 420, 72, {})
cases.sweep(r(fieldErrorRecipe), 'short', 140, 18, {})
cases.sweep(r(fieldErrorRecipe), 'long', 260, 18, {})
cases.sweep(r(inputGroupRecipe), 'rest', 260, 36, {})
cases.sweep(r(inputGroupRecipe), 'wide', 400, 72, {})
cases.add(r(inputGroupRecipe), 'narrow', 48, 32, {})
for (const edge of ['top', 'bottom'] as const) {
  cases.sweep(r(inputGroupRuleRecipe), edge, 260, 12, { edge })
  cases.add(r(inputGroupRuleRecipe), `${edge} wide`, 400, 12, { edge })
}
for (const [tag, params] of [
  ['rest', {}], ['filled', { filled: true }], ['active', { active: true }], ['active filled', { active: true, filled: true }],
  ['invalid', { invalid: true }], ['invalid active', { invalid: true, active: true }], ['disabled', { disabled: true, active: true }],
] as const) {
  cases.sweep(r(otpSlotRecipe), tag, 40, 44, params)
}
cases.sweep(r(promptInputBodyRecipe), 'rest', 320, 64, {})
cases.sweep(r(promptInputBodyRecipe), 'disabled', 320, 64, { disabled: true })
cases.add(r(promptInputBodyRecipe), 'narrow disabled', 9, 20, { disabled: true })

cases.write('packages/looseleaf_ink/test/fixtures/controls_fields.json')

// caretTile is private upstream: re-run its body here (kept identical to input-otp-ink.ts).
function caretTile(seed: string): string {
  const ink = new Ink(seed, { tier: 'lo', grain: false })
  ink.layer('rest', () => {
    const rng = ink.next('caret')
    const x = 4.5 + rng.range(-0.25, 0.25)
    ink.stroke(seg(x, 4, x + rng.range(-0.5, 0.5), 24, rng.range(-0.4, 0.4), 5), 'ink.brush', { color: 'current', width: 0.36, start: 'pool', end: 'pool', wobble: 0.5, simple: true })
    ink.stroke(seg(x - 3.3, 3.6 + rng.range(-0.2, 0.2), x + 3.3, 3.8 + rng.range(-0.2, 0.2), rng.range(-0.15, 0.15), 3), 'ink.brush', { color: 'current', width: 0.3, start: 'pool', end: 'pool', wobble: 0.3, simple: true })
    ink.stroke(seg(x - 3.3, 24.4 + rng.range(-0.2, 0.2), x + 3.3, 24.2 + rng.range(-0.2, 0.2), rng.range(-0.15, 0.15), 3), 'ink.brush', { color: 'current', width: 0.3, start: 'pool', end: 'pool', wobble: 0.3, simple: true })
  })
  const svg = ink.toSvg({ w: 9, h: 28, pad: 0 }).svg
  return `url("data:image/svg+xml,${encodeURIComponent(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 9 28" width="9" height="28">${svg}</svg>`)}")`
}
writeFixture('packages/looseleaf_ink/test/fixtures/controls_fields_tiles.json', {
  otpCss: otpCss(),
  otpCaret: ['otp|caret', 'a', 'slot-2'].map((seed) => ({ seed, out: caretTile(seed) })),
})
