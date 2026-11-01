// runRecipe frames of the surface recipes (accordion, alert, avatar, badge, card, kbd, overlay, sheet, …) and
// their helpers, for packages/looseleaf_ink/test/controls_surfaces_test.dart.
import { accordionRuleRecipe, accordionTriggerRecipe } from '@/lib/ink/recipes/accordion-ink'
import { alertRecipe } from '@/lib/ink/recipes/alert-ink'
import { alertMediaRecipe } from '@/lib/ink/recipes/alert-dialog-ink'
import { AVATAR_TONES, avatarBadgeRecipe, avatarCountRecipe, avatarFallbackRecipe, avatarRingRecipe, avatarTone, initials } from '@/lib/ink/recipes/avatar-ink'
import { badgeRecipe, badgeSizeList, badgeToneList, badgeVariantList, tallyWidth } from '@/lib/ink/recipes/badge-ink'
import { breadcrumbPageRecipe } from '@/lib/ink/recipes/breadcrumb-ink'
import { buttonGroupTextRecipe } from '@/lib/ink/recipes/button-group-ink'
import { hoverCardMediaRecipe } from '@/lib/ink/recipes/hover-card-ink'
import { kbdRecipe } from '@/lib/ink/recipes/kbd-ink'
import { closeMarkRecipe, pointerMark } from '@/lib/ink/recipes/overlay-ink'
import { sheetBindingRecipe } from '@/lib/ink/recipes/sheet-ink'
import { tableTiles } from '@/lib/ink/recipes/table-ink'
import type { Recipe } from '@/lib/ink/recipes'
import { register } from 'node:module'
import { join } from 'node:path'
import { pathToFileURL } from 'node:url'
import { RecipeCases } from '../recipe_frames'
import { writeFixture } from '../write'

// card-ink.ts imports the '@/lib/ink' barrel, which pulls in React; point that one specifier at shapes.ts.
const shapesUrl = pathToFileURL(join(process.cwd(), 'src/lib/ink/shapes.ts')).href
const hook = `export async function resolve(s, c, next) { return s === '@/lib/ink' ? { url: ${JSON.stringify(shapesUrl)}, shortCircuit: true } : next(s, c) }`
register(`data:text/javascript,${encodeURIComponent(hook)}`)
const { cardRuleRecipe } = await import('@/lib/ink/recipes/card-ink')

const cases = new RecipeCases()
const r = (x: unknown): Recipe<never> => x as Recipe<never>

cases.sweep(r(accordionRuleRecipe), 'rule', 320, 8, {})
cases.add(r(accordionRuleRecipe), 'narrow', 120, 8, {})
cases.sweep(r(accordionTriggerRecipe), 'trigger', 320, 44, {})
cases.add(r(accordionTriggerRecipe), 'narrow', 100, 36, {})
cases.add(r(accordionTriggerRecipe), 'disabled', 320, 44, { disabled: true })

for (const tone of ['default', 'destructive', 'info', 'success', 'warning', 'note'] as const) {
  cases.sweep(r(alertRecipe), tone, 320, 72, { tone })
}
cases.add(r(alertRecipe), 'wide', 420, 64, { tone: 'info' })
cases.add(r(alertRecipe), 'wide destructive rtl', 420, 64, { tone: 'destructive' }, { dir: 'rtl' })

for (const tone of ['default', 'danger', 'info'] as const) cases.sweep(r(alertMediaRecipe), tone, 48, 48, { tone })

for (const ring of ['ink', 'you', 'marker'] as const) {
  cases.sweep(r(avatarRingRecipe), ring, 40, 40, { ring })
  cases.add(r(avatarRingRecipe), `${ring} large`, 96, 96, { ring })
}
for (const tone of AVATAR_TONES) cases.add(r(avatarFallbackRecipe), tone, 40, 40, { tone })
cases.sweep(r(avatarFallbackRecipe), 'sky', 40, 40, { tone: 'sky' })
cases.add(r(avatarFallbackRecipe), 'large', 96, 96, { tone: 'grape' })
for (const status of ['online', 'away', 'busy', 'offline', 'marker'] as const) cases.add(r(avatarBadgeRecipe), status, 10, 10, { status })
cases.sweep(r(avatarBadgeRecipe), 'online', 12, 12, { status: 'online' })
cases.sweep(r(avatarCountRecipe), 'count', 40, 40, {})
cases.add(r(avatarCountRecipe), 'small', 24, 24, {})

for (const variant of badgeVariantList) {
  cases.sweep(r(badgeRecipe), variant, 64, 22, { variant, size: 'default' })
  cases.sweep(r(badgeRecipe), `${variant} hoverable`, 72, 24, { variant, size: 'default', hoverable: true })
  for (const size of badgeSizeList) cases.add(r(badgeRecipe), `${variant} ${size}`, 56 + 8 * badgeSizeList.indexOf(size), 20 + 2 * badgeSizeList.indexOf(size), { variant, size, hoverable: true })
}
for (const tone of badgeToneList) cases.add(r(badgeRecipe), `tone ${tone}`, 64, 22, { variant: 'default', size: 'default', tone })
for (const tally of [1, 4, 5, 7, 12]) {
  cases.add(r(badgeRecipe), `tally ${tally}`, 80, 22, { variant: 'outline', size: 'default', tally })
  cases.add(r(badgeRecipe), `tally ${tally} tall`, 96, 28, { variant: 'default', size: 'lg', tally })
}

cases.sweep(r(breadcrumbPageRecipe), 'page', 80, 24, {})
cases.sweep(r(buttonGroupTextRecipe), 'text', 96, 36, {})
cases.add(r(buttonGroupTextRecipe), 'wide', 400, 40, {})
cases.add(r(buttonGroupTextRecipe), 'wide calm', 400, 40, {}, { density: 'calm' })

for (const style of ['pencil', 'dashed', 'wavy'] as const) {
  for (const edge of ['top', 'bottom'] as const) cases.sweep(r(cardRuleRecipe), `${style} ${edge}`, 320, 8, { edge, style })
  cases.add(r(cardRuleRecipe), `${style} narrow`, 80, 8, { edge: 'top', style })
}

cases.sweep(r(hoverCardMediaRecipe), 'media', 64, 64, {})
cases.sweep(r(kbdRecipe), 'key', 24, 24, {})
cases.add(r(kbdRecipe), 'wide', 64, 26, {})

cases.sweep(r(closeMarkRecipe), 'ink', 32, 32, {})
cases.sweep(r(closeMarkRecipe), 'red', 32, 32, { tone: 'red' })
cases.add(r(closeMarkRecipe), 'explicit ink', 28, 28, { tone: 'ink' })

for (const edge of ['left', 'right', 'top', 'bottom'] as const) {
  for (const kind of ['spiral', 'holes'] as const) {
    const horizontal = edge === 'top' || edge === 'bottom'
    cases.sweep(r(sheetBindingRecipe), `${edge} ${kind}`, horizontal ? 360 : 40, horizontal ? 40 : 420, { edge, kind })
  }
}
cases.add(r(sheetBindingRecipe), 'short spiral', 40, 60, { edge: 'left', kind: 'spiral' })

cases.write('packages/looseleaf_ink/test/fixtures/controls_surfaces.json')

const names = ['Ada Lovelace', '  grace  hopper ', 'Émile Zola', 'x', '', '   ', 'Ünïcode Über Ñame', '😀 smile', 'Kevin', 'Jean-Luc Picard']
writeFixture('packages/looseleaf_ink/test/fixtures/controls_surfaces_helpers.json', {
  names: names.map((name) => ({ name, tone: avatarTone(name), initials: initials(name) })),
  tally: [0, 1, 3, 4, 5, 6, 9, 10, 13].flatMap((count) => [18, 22, 28].map((h) => ({ count, h, out: tallyWidth(count, h) }))),
  pointer: [
    { seed: 'pointer-a' },
    { seed: 'pointer-b', w: 30, h: 26 },
    { seed: 'pointer-c', tier: 'hi' },
    { seed: 'pointer-d', calm: true },
    { seed: 42, w: 16, h: 14 },
  ].map((o) => {
    const res = pointerMark(o.seed, { w: o.w, h: o.h, tier: o.tier as never, calm: o.calm })
    return { ...o, out: { svg: res.svg, w: res.w, h: res.h, pad: res.pad } }
  }),
  table: tableTiles(),
})
