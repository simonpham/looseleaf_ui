// Helpers of the paper recipes (paperSheet, paper-set parts, page and notebook holes, envelope, folder, bookmark,
// label tag and ticket geometry, clipboard clip, seals, desk pencil, typed signatures) and the faces carried by
// paper recipe frames, for packages/looseleaf_ink/test/paper_recipes_helpers_test.dart (seals in paper_seals.json).
import type { InkResult } from '@/lib/ink/builder'
import { splitFaces } from '@/lib/ink/paper/faces'
import { makeRng } from '@/lib/ink/rng'
import { paperSheet, sheetPad } from '@/lib/ink/recipes/paper-ink'
import { MIRROR, circleD, ellipseD, holePunch, litEdge, mirrorX, paperFill, polyD, reinforcement, stackSvg } from '@/lib/ink/recipes/paper-set-ink'
import { pageHoles } from '@/lib/ink/recipes/page-ink'
import { notebookHoles } from '@/lib/ink/recipes/notebook-ink'
import { perfRectD, stampBox } from '@/lib/ink/recipes/envelope-ink'
import { tabPoints } from '@/lib/ink/recipes/folder-ink'
import { clipboardClip } from '@/lib/ink/recipes/clipboard-ink'
import { ribbonPoly } from '@/lib/ink/recipes/bookmark-ink'
import { tagHole, tagPath } from '@/lib/ink/recipes/label-tag-ink'
import { ticketPath } from '@/lib/ink/recipes/ticket-ink'
import { sealArt, sealMarkList, sealVariantList, type SealParams } from '@/lib/ink/recipes/seal-ink'
import { pencil } from '@/lib/ink/recipes/desk-ink'
import { typedSignature } from '@/lib/ink/recipes/signature-pad-ink'
import '@/lib/ink/recipes/envelope-ink'
import '@/lib/ink/recipes/label-tag-ink'
import '@/lib/ink/recipes/ticket-ink'
import '@/lib/ink/recipes/notebook-ink'
import '@/lib/ink/recipes/clipboard-ink'
import { runCases, type RecipeCase } from '../recipe_cases'
import { writeFixture } from '../write'

const res = (r: InkResult) => ({ svg: r.svg, w: r.w, h: r.h, pad: r.pad, layers: r.layers })
const withParts = (r: InkResult) => ({ ...res(r), parts: r.parts })
const calls: Array<{ fn: string; args: unknown[]; out: unknown }> = []
const add = (fn: string, args: unknown[], out: unknown) => calls.push({ fn, args, out })

const sheets: Array<[string, number, number, Record<string, unknown>, Record<string, unknown>]> = [
  ['a', 240, 160, { stock: 'paper', edge: 'cut' }, {}],
  ['b', 260, 180, { stock: 'kraft', edge: 'torn' }, { tier: 'hi' }],
  ['c', 180, 180, { stock: 'sticky-yellow', edge: 'cut', chamfer: 16 }, { faces: { tiles: true } }],
  ['d', 200, 150, { stock: 'card', edge: { top: 'torn' } }, { calm: true, faces: { id: 'x-' } }],
  ['e', 300, 300, { stock: 'napkin', edge: 'scallop', shadow: 'none' }, { faces: { tiles: true, id: 'nap' } }],
  ['f', 160, 300, { stock: 'receipt', edge: { top: 'zig', bottom: 'zig' }, shadow: 'lift' }, {}],
]
for (const [seed, w, h, p, o] of sheets) add('paperSheet', [seed, w, h, p, o], withParts(paperSheet(seed, w, h, p as never, o as never)))

for (const edge of ['cut', 'torn', 'deckle', 'perf', 'zig', 'scallop', 'crimp']) add('sheetPad', [edge], sheetPad(edge as never))
add('sheetPad', [{ top: 'torn' }], sheetPad({ top: 'torn' }))

add('ellipseD', [10, 12.34, 5.5, 3.25], ellipseD(10, 12.34, 5.5, 3.25))
add('circleD', [3, 4, 2.2], circleD(3, 4, 2.2))
add('polyD', [[[0, 0], [1.23, 4.56], [7.89, 0.1]], true], polyD([[0, 0], [1.23, 4.56], [7.89, 0.1]], true))
add('mirrorX', [123.45, '<path/>'], mirrorX(123.45, '<path/>'))
add('MIRROR', [80], MIRROR(80))
add('litEdge', ['M0 0H10', undefined], litEdge('M0 0H10'))
add('litEdge', ['M0 0H10', 0.4], litEdge('M0 0H10', 0.4))
for (const [cx, cy, r, tilt] of [[22, 40, 7.5, 0], [15.3, 0, 3.9, 20], [100.12, 55.5, 6.2, -17.3]]) {
  add('holePunch', [`ll-h${cx}`, cx, cy, r, tilt], holePunch(`ll-h${cx}`, cx, cy, r, tilt))
  add('reinforcement', [cx, cy, r], reinforcement(cx, cy, r))
}
const fills: Array<[number, string, Record<string, unknown>]> = [
  [12345, 'M0 0H100V60H0z', { stock: 'paper' }],
  [987654, 'M0 0H100V60H0z', { stock: 'kraft', id: 'b', shadow: true }],
  [42, 'M0 0H100V60H0zM10 10h5v5h-5z', { stock: 'card', evenodd: true, shadow: true, inset: [2, 1, 1, 2], edge: 0.3 }],
  [7, 'M1 0.5L50 -30L99 0.5z', { stock: 'paper', id: 'h', shadow: true, far: false }],
  [99, 'M0 0H80V40H0z', { stock: 'sticky-pink', shadow: 'lift' }],
  [100, 'M0 0H80V40H0z', { stock: 'sticky-pink', shadow: 'hair' }],
  [101, 'M0 0H80V40H0z', { stock: 'index-card', shadow: false }],
]
for (const [seed, d, o] of fills) add('paperFill', [seed, d, o], paperFill(seed, d, o as never))
for (const [w, h, count, fills2] of [[200, 120, 3, undefined], [150, 90, 1, ['card', 'slip']], [100, 100, 0, undefined]] as const) {
  add('stackSvg', [w, h, count, `st-${w}`, `ll-st${w}`, fills2], stackSvg(w, h, count, makeRng(`st-${w}`), `ll-st${w}`, fills2 as never))
}

for (const holes of ['none', 'start', 'top']) {
  for (const [w, h] of [[320, 420], [320, 380], [320, 260], [320, 190], [320, 150], [200, 300], [900, 600]]) add('pageHoles', [w, h, holes], pageHoles(w, h, holes as never))
}
for (const binding of ['spiral', 'rings', 'stitched', 'none']) {
  for (const len of [400, 360, 250, 190, 170, 60, 30]) add('notebookHoles', [len, binding], notebookHoles(len, binding as never))
}
for (const [x, y, w, h, r, pitch] of [[10, 12, 40, 49, 2.1, 7], [0, 0, 30, 36.6, 2.1, 7], [5.5, 6.5, 12, 10, 1, 7]]) add('perfRectD', [x, y, w, h, r, pitch], perfRectD(x, y, w, h, r, pitch))
for (const w of [180, 380, 700, 120]) add('stampBox', [w], stampBox(w))
for (const [w, h, top, bottom] of [[120, 34, 4, 0], [120, 34, 0, 4], [80, 30, 4, 2]]) add('tabPoints', [w, h, top, `tab-${w}-${top}`, bottom], tabPoints(w, h, top, makeRng(`tab-${w}-${top}`), bottom))
for (const [w, h] of [[22, 56], [60, 40], [10, 10]]) add('ribbonPoly', [w, h], ribbonPoly(w, h))
for (const shape of ['price', 'round', 'luggage']) {
  add('tagHole', [110, 170, shape], tagHole(110, 170, shape as never))
  for (const mirror of [false, true]) add('tagPath', [110, 170, shape, `tag-${shape}`, mirror], tagPath(110, 170, shape as never, makeRng(`tag-${shape}`), mirror))
  add('tagPath', [60, 40, shape, `tag-s-${shape}`, false], tagPath(60, 40, shape as never, makeRng(`tag-s-${shape}`)))
}
for (const [w, h, sx, holes] of [[320, 130, 240, []], [320, 130, 80, [[200, 100]]], [320, 130, -1, []], [160, 50, 120, [[90.5, 20.25]]], [100, 40, 100, []]] as const) {
  add('ticketPath', [w, h, sx, holes], ticketPath(w, h, sx, holes as never))
}

for (const [seed, o] of [['clip-a', {}], ['clip-b', { width: 160 }], ['clip-c', { width: 80, tier: 'hi' }], ['clip-d', { calm: true }]] as const) {
  add('clipboardClip', [seed, o], res(clipboardClip(seed, o as never)))
}

for (const [seed, o] of [['pen-a', {}], ['pen-b', { length: 120, color: 'sky' }], ['pen-c', { length: 300, color: 'tomato', tier: 'hi' }], ['pen-d', { length: 60, calm: true }]] as const) {
  add('pencil', [seed, o], res(pencil(seed, o as never)))
}

for (const [text, w, h, seed, color] of [
  ['Ada Lovelace', 360, 160, 's1', undefined],
  ['  Grace Hopper  ', 200, 80, 's2', 'ink'],
  ['A very long signature name that will need to shrink to fit the pad nicely', 300, 120, 's3', undefined],
  ['', 300, 120, 's4', undefined],
  ['   ', 300, 120, 's5', undefined],
  ['Jo', 500, 300, 's6', 'tomato'],
] as const) {
  add('typedSignature', [text, w, h, seed, color], typedSignature(text, w, h, seed, color as never))
}

const seals: SealParams[] = []
for (const variant of sealVariantList) {
  seals.push({ variant, text: 'OK' })
  seals.push({ variant, text: 'Best', sub: 'since 1999', tone: 'sky', textColor: 'tomato', deco: 'star' })
  seals.push({ variant })
  for (const mark of sealMarkList) seals.push({ variant, mark, tone: 'lemon' })
}
for (const variant of ['rosette', 'medal'] as const) {
  seals.push({ variant, text: 'Winner', ribbon: 'grass', deco: 'tick' })
  seals.push({ variant, text: 'A', ribbon: 'tomato', mark: 'star' })
}
seals.push({ variant: 'ring', text: 'Approved', ring: 'Quality checked' })
seals.push({ variant: 'ring', text: 'Hi', ring: 'Looseleaf · seal of approval · ', tone: 'grass' })
seals.push({ variant: 'ring', ring: 'x', mark: 'star' })
seals.push({ variant: 'wax', text: 'ab' })
seals.push({ variant: 'wax', text: 'Z', tone: 'grape' })
seals.push({ variant: 'scallop', text: 'Sale', deco: 'sparkle' })
seals.push({ variant: 'medal', text: '1st', deco: 'swoosh' })
seals.push({ variant: 'plate', text: '50', deco: 'percent' })
const sealCalls: Array<{ fn: string; args: unknown[]; out: unknown }> = []
for (const [i, p] of seals.entries()) {
  for (const [size, tier] of [[24, 'lo'], [96, 'lo'], [72.4, 'hi']] as const) {
    const seed = `seal-${i}-${size}`
    sealCalls.push({ fn: 'sealArt', args: [p, size, seed, tier], out: res(sealArt(p, size, seed, tier)) })
  }
}
writeFixture('packages/looseleaf_ink/test/fixtures/paper_seals.json', { calls: sealCalls })

const faced: RecipeCase[] = [
  { name: 'faces sheet', recipe: 'paper-sheet', w: 240, h: 160, params: { stock: 'kraft', edge: 'torn' } },
  { name: 'faces sheet none', recipe: 'paper-sheet', w: 240, h: 160, params: { stock: 'parchment', edge: 'deckle', shadow: 'none' } },
  { name: 'faces sticky', recipe: 'paper-sheet', w: 180, h: 180, params: { stock: 'sticky-yellow', edge: 'cut', chamfer: 16 } },
  { name: 'faces envelope back', recipe: 'envelope-back', w: 320, h: 200, params: { stock: 'kraft' } },
  { name: 'faces envelope front', recipe: 'envelope-front', w: 380, h: 220, params: { stock: 'paper', stamp: 'sky', postmark: true, airmail: true } },
  { name: 'faces label tag', recipe: 'label-tag-sheet', w: 110, h: 170, params: { stock: 'card', shape: 'price', string: 40, twine: 'natural', eyelet: 'brass' } },
  { name: 'faces ticket', recipe: 'ticket-sheet', w: 320, h: 130, params: { stock: 'card', stub: 'end', stubWidth: 80, punched: true } },
  { name: 'faces folder tab', recipe: 'folder-tab', w: 120, h: 34, params: { stock: 'kraft', disabled: false } },
  { name: 'faces clipboard', recipe: 'clipboard-board', w: 300, h: 400, params: { tone: 'hardboard' } },
  { name: 'faces notebook cover rtl', recipe: 'notebook-cover', w: 260, h: 340, params: { tone: 'sky', band: true }, dir: 'rtl' },
]
const faces = (runCases(faced) as Array<{ name: string; out: { layers: string[]; parts: Record<string, string> } }>).map((c) => ({
  name: c.name,
  layers: c.out.layers,
  parts: c.out.parts,
  split: Object.fromEntries(
    Object.entries(c.out.parts).map(([k, v]) => [k, splitFaces(v).map((x) => (typeof x === 'string' ? { markup: x } : { face: JSON.stringify(x) }))]),
  ),
}))

writeFixture('packages/looseleaf_ink/test/fixtures/paper_recipes_helpers.json', { calls, faces })
