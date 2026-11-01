// runRecipe frames of the navigation recipes (calendar, command, menubar, navigation menu,
// resizable, scroll area, sidebar, tabs) and the calendar / underline tiles, for
// packages/looseleaf_ink/test/controls_navigation_test.dart.
import { bandTile, calendarDropdownRecipe, calendarGridRecipe, focusTile, ringTile, underlineTile, washTile } from '@/lib/ink/recipes/calendar-ink'
import { commandInputRecipe } from '@/lib/ink/recipes/command-ink'
import { menubarRecipe } from '@/lib/ink/recipes/menubar-ink'
import { navBaselineRecipe, navTabRecipe, underlineMark } from '@/lib/ink/recipes/navigation-menu-ink'
import { resizableRecipe } from '@/lib/ink/recipes/resizable-ink'
import { scrollThumbRecipe, scrollTrackRecipe } from '@/lib/ink/recipes/scroll-area-ink'
import { sidebarMarkRecipe, sidebarRuleRecipe } from '@/lib/ink/recipes/sidebar-ink'
import { tabsRecipe } from '@/lib/ink/recipes/tabs-ink'
import type { Recipe } from '@/lib/ink/recipes'
import { RecipeCases } from '../recipe_frames'
import { writeFixture } from '../write'

const cases = new RecipeCases()
const r = (x: unknown): Recipe<never> => x as Recipe<never>

cases.sweep(r(calendarGridRecipe), '6 rows', 280, 268, { rows: 6 })
cases.sweep(r(calendarGridRecipe), 'week numbers', 310, 228, { rows: 5, weekNumbers: true })
cases.add(r(calendarGridRecipe), 'short', 280, 40, { rows: 0 })
cases.sweep(r(calendarDropdownRecipe), 'rest', 96, 32, {})
cases.sweep(r(calendarDropdownRecipe), 'disabled', 96, 32, { disabled: true })

cases.sweep(r(commandInputRecipe), 'rest', 320, 40, {})

cases.sweep(r(menubarRecipe), 'rest', 300, 40, {})
cases.sweep(r(menubarRecipe), 'wide', 480, 36, {})
cases.add(r(menubarRecipe), 'tiny', 30, 24, {})

for (const role of ['trigger', 'link'] as const) {
  cases.sweep(r(navTabRecipe), role, 110, 36, { role })
  cases.sweep(r(navTabRecipe), `${role} disabled`, 110, 36, { role, disabled: true })
}
cases.sweep(r(navBaselineRecipe), 'rest', 300, 4, {})
cases.add(r(navBaselineRecipe), 'wide', 500, 4, {})

for (const line of ['vertical', 'horizontal'] as const) {
  const [w, h] = line === 'vertical' ? [10, 240] : [240, 10]
  cases.sweep(r(resizableRecipe), `${line} grip`, w, h, { line, grip: true })
  cases.sweep(r(resizableRecipe), `${line}`, w, h, { line, grip: false })
  cases.sweep(r(resizableRecipe), `${line} disabled`, w, h, { line, grip: true, disabled: true })
}

for (const orientation of ['vertical', 'horizontal'] as const) {
  const [w, h] = orientation === 'vertical' ? [10, 200] : [200, 10]
  cases.sweep(r(scrollTrackRecipe), orientation, w, h, { orientation })
  cases.sweep(r(scrollThumbRecipe), orientation, w, h * 0.4, { orientation })
  cases.add(r(scrollThumbRecipe), `${orientation} short`, orientation === 'vertical' ? 8 : 30, orientation === 'vertical' ? 30 : 8, { orientation })
}

for (const [active, outline] of [[true, false], [false, true], [true, true], [false, false]] as const) {
  cases.sweep(r(sidebarMarkRecipe), `active ${active} outline ${outline}`, 220, 32, { active, outline })
}
cases.add(r(sidebarMarkRecipe), 'wide outline', 400, 32, { active: true, outline: true })
cases.add(r(sidebarMarkRecipe), 'tiny', 10, 8, { active: true, outline: false })
cases.sweep(r(sidebarRuleRecipe), 'rest', 4, 400, {})

for (const variant of ['default', 'line'] as const) {
  for (const orientation of ['horizontal', 'vertical'] as const) {
    const [w, h] = orientation === 'vertical' ? [120, 32] : [96, 32]
    cases.sweep(r(tabsRecipe), `${variant} ${orientation}`, w, h, { variant, orientation })
    cases.sweep(r(tabsRecipe), `${variant} ${orientation} disabled`, w, h, { variant, orientation, disabled: true })
  }
}
cases.add(r(tabsRecipe), 'narrow', 8, 6, { variant: 'default', orientation: 'horizontal' })

cases.write('packages/looseleaf_ink/test/fixtures/controls_navigation.json')

const seeds = ['a', 'cal|ring|1', 'cal|band|0']
writeFixture('packages/looseleaf_ink/test/fixtures/controls_navigation_tiles.json', {
  ring: seeds.map((seed) => ({ seed, out: ringTile(seed) })),
  wash: seeds.map((seed) => ({ seed, out: washTile(seed) })),
  underline: seeds.flatMap((seed) => [false, true].map((double) => ({ seed, double, out: underlineTile(seed, double) }))),
  focus: seeds.map((seed) => ({ seed, out: focusTile(seed) })),
  band: seeds.flatMap((seed) => [[false, false], [true, false], [false, true], [true, true]].map(([left, right]) => ({ seed, left, right, out: bandTile(seed, left, right) }))),
  underlineMark: [
    { seed: 'nav', o: {} },
    { seed: 'nav-wide', o: { w: 140, h: 10 } },
    { seed: 'nav-hi', o: { tier: 'hi' } },
    { seed: 'nav-calm', o: { calm: true } },
    { seed: 7, o: { w: 60 } },
  ].map(({ seed, o }) => ({ seed, o, out: underlineMark(seed, o as never) })),
})
