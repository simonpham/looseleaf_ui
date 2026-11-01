// runRecipe frames of the paper recipes (sheet, hand rules, title mark, page, notebook, napkin, index card,
// envelope, folder, clipboard, bookmark, label tag, ticket, separator, marquee, sticky note, signature pad),
// for packages/looseleaf_ink/test/paper_recipes_test.dart.
import '@/lib/ink/recipes/paper-ink'
import '@/lib/ink/recipes/paper-set-ink'
import '@/lib/ink/recipes/page-ink'
import '@/lib/ink/recipes/notebook-ink'
import '@/lib/ink/recipes/napkin-ink'
import '@/lib/ink/recipes/index-card-ink'
import '@/lib/ink/recipes/envelope-ink'
import '@/lib/ink/recipes/folder-ink'
import '@/lib/ink/recipes/clipboard-ink'
import '@/lib/ink/recipes/bookmark-ink'
import '@/lib/ink/recipes/label-tag-ink'
import '@/lib/ink/recipes/ticket-ink'
import '@/lib/ink/recipes/separator-ink'
import '@/lib/ink/recipes/marquee-ink'
import '@/lib/ink/recipes/sticky-note-ink'
import '@/lib/ink/recipes/signature-pad-ink'
import { runCases, spread, type RecipeCase } from '../recipe_cases'
import { writeFixture } from '../write'

const cases: RecipeCase[] = []

const sheets: Array<[string, Record<string, unknown>, number, number]> = [
  ['paper cut', { stock: 'paper', edge: 'cut' }, 240, 160],
  ['kraft torn', { stock: 'kraft', edge: 'torn' }, 260, 180],
  ['card top torn', { stock: 'card', edge: { top: 'torn' } }, 220, 140],
  ['card sides deckle', { stock: 'card', edge: { left: 'deckle', right: 'torn' } }, 200, 150],
  ['sticky chamfer', { stock: 'sticky-yellow', edge: 'cut', chamfer: 18 }, 180, 180],
  ['sticky pink chamfer torn', { stock: 'sticky-pink', edge: { top: 'torn' }, chamfer: 14 }, 160, 160],
  ['napkin scallop', { stock: 'napkin', edge: 'scallop' }, 300, 300],
  ['napkin small', { stock: 'napkin', edge: 'cut' }, 90, 70],
  ['parchment deckle none', { stock: 'parchment', edge: 'deckle', shadow: 'none' }, 260, 200],
  ['index perf lift', { stock: 'index-card', edge: 'perf', shadow: 'lift' }, 300, 180],
  ['receipt zig', { stock: 'receipt', edge: { top: 'zig', bottom: 'zig' } }, 160, 320],
  ['photo crimp', { stock: 'photo', edge: 'crimp' }, 200, 200],
  ['graph cut hair', { stock: 'graph', edge: 'cut', shadow: 'hair' }, 280, 200],
  ['pad perf', { stock: 'pad', edge: { top: 'perf' } }, 240, 300],
]
for (const [name, params, w, h] of sheets) cases.push(...spread(`paper-sheet ${name}`, 'paper-sheet', w, h, params))

for (const params of [{}, { paper: 'ruled' }, { paper: 'pad' }]) {
  cases.push(...spread(`paper-rules-hand ${JSON.stringify(params)}`, 'paper-rules-hand', 320, 220, params))
}

for (const kind of ['single', 'double', 'wavy', 'highlight']) {
  cases.push(...spread(`title-mark ${kind}`, 'paper-set-title-mark', 160, 30, { kind }))
  for (const tone of ['you', 'red', 'marker']) {
    cases.push({ name: `title-mark ${kind} ${tone}`, recipe: 'paper-set-title-mark', w: 120, h: 26, params: { kind, tone } })
  }
}

for (const holes of ['none', 'start', 'top']) {
  for (const h of [420, 260, 150]) {
    cases.push(...spread(`page ${holes} ${h}`, 'page-decor', 320, h, { holes, reinforce: h === 420, stain: h !== 150 }))
  }
}
cases.push({ name: 'page top narrow', recipe: 'page-decor', w: 200, h: 300, params: { holes: 'top', reinforce: true, stain: true } })
cases.push({ name: 'page top wide', recipe: 'page-decor', w: 900, h: 600, params: { holes: 'top', reinforce: false, stain: true } })

for (const binding of ['spiral', 'rings', 'stitched', 'none']) {
  for (const side of ['start', 'top']) {
    cases.push(...spread(`notebook ${binding} ${side}`, 'notebook-decor', 300, 400, { binding, side, pages: 3, tone: 'steel', curl: true }))
  }
  cases.push({ name: `notebook ${binding} short sky`, recipe: 'notebook-decor', w: 240, h: 170, params: { binding, side: 'start', pages: 0, tone: 'sky' } })
  cases.push({ name: `notebook ${binding} mid grape`, recipe: 'notebook-decor', w: 260, h: 250, params: { binding, side: 'start', pages: 1, tone: 'grape', curl: false } })
  cases.push({ name: `notebook ${binding} tiny`, recipe: 'notebook-decor', w: 120, h: 50, params: { binding, side: 'start', pages: 2, tone: 'steel' } })
}

for (const [tone, band] of [['ink', false], ['sky', true], ['tomato', false], ['grass', true]] as const) {
  cases.push(...spread(`notebook-cover ${tone} ${band}`, 'notebook-cover', 260, 340, { tone, band }))
}
cases.push({ name: 'notebook-cover narrow band', recipe: 'notebook-cover', w: 120, h: 160, params: { tone: 'lemon', band: true } })

for (const fold of ['quarter', 'half', 'none']) {
  for (const stain of [false, true]) cases.push(...spread(`napkin ${fold} ${stain}`, 'napkin-decor', 300, 300, { fold, stain }))
}
cases.push({ name: 'napkin small stain', recipe: 'napkin-decor', w: 120, h: 90, params: { fold: 'quarter', stain: true } })

for (const [hole, flag, stack] of [[true, 'none', 0], [false, 'tomato', 2], [true, 'sky', 3], [false, 'none', 1]] as const) {
  cases.push(...spread(`index-card ${hole} ${flag} ${stack}`, 'index-card-decor', 300, 180, { hole, flag, stack }))
}

for (const stock of ['paper', 'kraft', 'parchment']) cases.push(...spread(`envelope-back ${stock}`, 'envelope-back', 320, 200, { stock }))
cases.push({ name: 'envelope-back short', recipe: 'envelope-back', w: 140, h: 80, params: { stock: 'card' } })
for (const [stamp, postmark, airmail] of [['none', false, false], ['sky', true, false], ['tomato', true, true], ['none', true, true], ['grape', false, true]] as const) {
  cases.push(...spread(`envelope-front ${stamp} ${postmark} ${airmail}`, 'envelope-front', 380, 220, { stock: 'paper', stamp, postmark, airmail }))
}
cases.push({ name: 'envelope-front small', recipe: 'envelope-front', w: 180, h: 110, params: { stock: 'kraft', stamp: 'lemon', postmark: true, airmail: true } })
cases.push({ name: 'envelope-front wide', recipe: 'envelope-front', w: 700, h: 360, params: { stock: 'card', stamp: 'teal', postmark: true, airmail: false } })

for (const stock of ['kraft', 'card']) {
  for (const disabled of [false, true]) cases.push(...spread(`folder-tab ${stock} ${disabled}`, 'folder-tab', 120, 34, { stock, disabled }))
}
for (const crease of [true, false]) cases.push(...spread(`folder-body ${crease}`, 'folder-body', 360, 240, { crease }))

for (const tone of ['hardboard', 'sky', 'tomato']) {
  cases.push(...spread(`clipboard-board ${tone}`, 'clipboard-board', 300, 400, { tone }))
  cases.push({ name: `clipboard-board ${tone} wide`, recipe: 'clipboard-board', w: 420, h: 520, params: { tone } })
}

for (const tone of ['tomato', 'sky']) {
  for (const mode of ['toggle', 'static']) {
    for (const disabled of [false, true]) cases.push(...spread(`bookmark ${tone} ${mode} ${disabled}`, 'bookmark-ribbon', 22, 56, { tone, mode, disabled }))
  }
}
cases.push({ name: 'bookmark wide', recipe: 'bookmark-ribbon', w: 60, h: 40, params: { tone: 'grass', mode: 'toggle', disabled: false } })

for (const shape of ['price', 'round', 'luggage']) {
  for (const [eyelet, twine] of [['brass', 'natural'], ['steel', 'sky'], ['none', 'tomato']] as const) {
    const [w, h] = shape === 'luggage' ? [200, 110] : [110, 170]
    cases.push(...spread(`label-tag ${shape} ${eyelet}`, 'label-tag-sheet', w, h, { stock: 'card', shape, string: 40, twine, eyelet }))
  }
}
cases.push({ name: 'label-tag kraft short string', recipe: 'label-tag-sheet', w: 90, h: 140, params: { stock: 'kraft', shape: 'price', string: 12.5, twine: 'natural', eyelet: 'brass' } })

for (const stub of ['end', 'start', 'none']) {
  for (const punched of [false, true]) cases.push(...spread(`ticket ${stub} ${punched}`, 'ticket-sheet', 320, 130, { stock: 'card', stub, stubWidth: 80, punched }))
}
cases.push({ name: 'ticket short', recipe: 'ticket-sheet', w: 160, h: 50, params: { stock: 'kraft', stub: 'end', stubWidth: 40, punched: true } })

for (const variant of ['pencil', 'dashed', 'wavy', 'dotted', 'tape', 'stitched', 'torn']) {
  cases.push(...spread(`separator ${variant}`, 'separator', 260, 12, { variant, orientation: 'horizontal' }))
  cases.push(...spread(`separator ${variant} vertical`, 'separator', 12, 180, { variant, orientation: 'vertical' }))
  cases.push({ name: `separator ${variant} long`, recipe: 'separator', w: 520, h: 16, params: { variant, orientation: 'horizontal' } })
  cases.push({ name: `separator ${variant} tiny`, recipe: 'separator', w: 8, h: 10, params: { variant, orientation: 'horizontal' } })
}

cases.push(...spread('marquee-band', 'marquee-band', 320, 28, {}))
cases.push(...spread('marquee-band dots sky', 'marquee-band', 260, 24, { kind: 'washi-dots', color: 'sky' }))
cases.push({ name: 'marquee-band masking', recipe: 'marquee-band', w: 200, h: 22, params: { kind: 'masking' } })
cases.push({ name: 'marquee-band kraft', recipe: 'marquee-band', w: 200, h: 22, params: { kind: 'kraft', color: 'grape' } })
for (const paused of [false, true]) cases.push(...spread(`marquee-control ${paused}`, 'marquee-control', 28, 28, { paused }))
cases.push({ name: 'marquee-control big', recipe: 'marquee-control', w: 40, h: 36, params: { paused: true } })

cases.push(...spread('sticky-note', 'sticky-note-decor', 200, 200, {}))
cases.push({ name: 'sticky-note small', recipe: 'sticky-note-decor', w: 90, h: 80, params: {} })

for (const params of [{}, { invalid: false }, { invalid: true }]) {
  cases.push(...spread(`signature-baseline ${JSON.stringify(params)}`, 'signature-baseline', 360, 160, params))
}
cases.push({ name: 'signature-baseline short', recipe: 'signature-baseline', w: 160, h: 60, params: {} })

writeFixture('packages/looseleaf_ink/test/fixtures/paper_recipes.json', { frames: runCases(cases) })
