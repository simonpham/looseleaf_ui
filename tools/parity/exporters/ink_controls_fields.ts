// runRecipe frames of the field recipes (input, textarea, select family, combobox), for
// packages/looseleaf_ink/test/controls_fields_test.dart.
import { inputRecipe } from '@/lib/ink/recipes/input-ink'
import { textareaRecipe } from '@/lib/ink/recipes/textarea-ink'
import { selectRecipe } from '@/lib/ink/recipes/select-ink'
import { nativeSelectRecipe } from '@/lib/ink/recipes/native-select-ink'
import { datePickerRecipe } from '@/lib/ink/recipes/date-picker-ink'
import { chipToneList, comboboxChipRecipe, comboboxChipsRecipe, comboboxTriggerRecipe } from '@/lib/ink/recipes/combobox-ink'
import type { Recipe } from '@/lib/ink/recipes'
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

cases.write('packages/looseleaf_ink/test/fixtures/controls_fields.json')
