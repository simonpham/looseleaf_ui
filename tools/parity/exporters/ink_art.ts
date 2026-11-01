// The art library through its drawing entry points (drawSkeleton, dieCut, renderSticker, drawMascot), the art DSL,
// glyph lettering, badges and rubber stamps, for packages/looseleaf_ink/test/art_*_test.dart.
import { badgeSkeleton, dieCut, drawSkeleton, renderSticker, stamp, variantFor, partsFor, type DieCutOpts, type DrawOpts } from '@/lib/ink/art-draw'
import { checkPath, parsePath, polygonsOf, tokenize, kindOfDef, validateArt } from '@/lib/ink/art/dsl'
import { capHeight, hasGlyph, measureText, textPath } from '@/lib/ink/art/glyph-text'
import { drawMascot, mascotVariant } from '@/lib/ink/art/mascot-draw'
import { icons, iconBatches, kebabIconName, resolveIconName } from '@/lib/ink/art/icons'
import { doodles } from '@/lib/ink/art/doodles'
import { stickers, stickerBatches } from '@/lib/ink/art/stickers'
import { mascot, mascotProps } from '@/lib/ink/art/mascots'
import { scenes } from '@/lib/ink/art/scenes'
import type { ArtDef, BadgeGen, StampGen } from '@/lib/ink/art/types'
import { makeRng } from '@/lib/ink/rng'
import type { InkResult } from '@/lib/ink/builder'
import { mkdirSync, readdirSync, unlinkSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'

const MAX_BYTES = 900_000

/** Writes compact JSON fixtures `<name>_1.json`, `<name>_2.json`, … of at most MAX_BYTES each, splitting `cases`. */
function writeChunks(name: string, cases: unknown[], extra: Record<string, unknown> = {}): void {
  const root = process.env.LOOSELEAF_UI_ROOT
  if (!root) throw new Error('LOOSELEAF_UI_ROOT is not set; run through export.sh')
  const dir = join(root, fixtures)
  mkdirSync(dir, { recursive: true })
  for (const f of readdirSync(dir)) if (new RegExp(`^${name}_\\d+\\.json$`).test(f)) unlinkSync(join(dir, f))
  const chunks: unknown[][] = [[]]
  let size = JSON.stringify(extra).length
  for (const c of cases) {
    const len = JSON.stringify(c).length + 1
    if (size + len > MAX_BYTES && chunks[chunks.length - 1].length) {
      chunks.push([])
      size = 0
    }
    chunks[chunks.length - 1].push(c)
    size += len
  }
  chunks.forEach((chunk, i) => {
    const file = `${name}_${i + 1}.json`
    writeFileSync(join(dir, file), JSON.stringify({ ...(i === 0 ? extra : {}), cases: chunk }) + '\n')
    console.log(`    ${fixtures}/${file}`)
  })
}

const out = (r: InkResult & { variant?: string; nib?: number; k?: number; off?: number; border?: number }) => ({
  svg: r.svg,
  pad: r.pad,
  w: r.w,
  h: r.h,
  layers: r.layers,
  bbox: r.bbox,
  ...(r.variant ? { variant: r.variant, nib: r.nib, k: r.k } : {}),
  ...(r.off !== undefined ? { off: r.off, border: r.border } : {}),
})

const fixtures = 'packages/looseleaf_ink/test/fixtures'

// The DSL.
const dslPaths = [
  'M5.1 8.7 L11.3 14.9 Q12.2 15.8 13.1 14.9 L18.8 9.4',
  'M4.3 12.7 Q12 11.7 19.8 12.1 M14.1 6.5 L20.3 12 L15.4 17.1',
  'O 32 40.3 16.8',
  'O 32 40.4 17.4 17.5 M3 3 l2 2 1.5 -.5',
  'M12.4 21.6 L52 21 C58.4 21.4 61 26 60.8 32.4 C60.6 38.8 58.2 43.2 52 43.8 L12 44.4 C6 44 3.4 39 3.6 32.6 C3.6 26 6 22 12.4 21.6 Z',
  'E119.0 75.0 7.0 7.0 -72 -28 E119.0 75.0 7.0 7.0 5 50 E 30 30 4 6 0 180',
  'M1 1 L2 2 Z M3 3 L4 4 L5 3 L6 6 Z',
  'M0 0,5 5 L-3.5e-1 .5 l1e1 -2 Z',
  'M3 4 L5.',
  'Q1 2 3 4',
  'Z M1 1 l1 1 l1 0 l0 1 Z O 5 5 2 E 5 5 2 2 0 90',
]
const pick = <T>(xs: T[], every: number): T[] => xs.filter((_, i) => i % every === 0)
const realPaths: string[] = []
for (const def of Object.values(icons) as ArtDef[]) for (const p of def.parts) if (p[0] === 's') realPaths.push(p[1])
for (const def of Object.values(doodles) as ArtDef[]) for (const p of def.parts) if (p[0] === 'f') realPaths.push(p[2])
const dsl = {
  tokenize: dslPaths.map((d) => ({ d, out: tokenize(d) })),
  parse: [...dslPaths, ...pick(realPaths, 23)].flatMap((d, i) => [
    { d, out: parsePath(d) },
    { d, step: 0.35, seed: `dsl${i}`, out: parsePath(d, { step: 0.35, rnd: makeRng(`dsl${i}`) }) },
  ]),
  polygons: [...dslPaths, ...pick(realPaths, 31)].map((d, i) => ({ d, seed: `poly${i}`, out: polygonsOf(d, { rnd: makeRng(`poly${i}`) }) })),
}

// Lettering.
const words = ['Approved', 'hello, world!', 'A+B=C', 'yay 100%', '', ' ', '#1 (best)', 'Qq?', 'ünï', 'WAVY-LINE', "it's 3:45"]
const text = {
  measure: words.flatMap((t) => (['hand', 'type'] as const).flatMap((font) => [1, 13.5].map((size) => ({ font, t, size, spacing: size > 1 ? 1.2 : 0, out: measureText(font, t, size, size > 1 ? 1.2 : 0) })))),
  cap: [1, 12, 33.3].flatMap((size) => (['hand', 'type'] as const).map((font) => ({ font, size, out: capHeight(font, size) }))),
  glyphs: ['A', 'z', ' ', '~', '%', 'É', '9'].flatMap((ch) => ['hand', 'type', 'serif'].map((font) => ({ font, ch, out: hasGlyph(font, ch) }))),
  paths: words.flatMap((t, i) =>
    [
      {},
      { font: 'type', anchor: 'start', spacing: 1.5, jitter: 0.35 },
      { anchor: 'end', jitter: 1, rot: -8, squeeze: 0.8, q: 20 },
      { font: 'type', rot: 33, jitter: 0.1, q: 100 },
    ].map((o, j) => {
      const seed = `text${i}:${j}`
      return { t, x: 40.5, y: 22.25, em: 9 + j * 3.3, seed, o, out: textPath(t, 40.5, 22.25, 9 + j * 3.3, makeRng(seed), o as never) }
    }),
  ),
}

// Badges and stamps.
const shapes = ['scallop', 'starburst', 'rosette', 'banner', 'tag', 'ticket', 'plate', 'shield', 'medal'] as const
const decos = ['tick', 'star', 'sparkle', 'swoosh', 'percent'] as const
const badgeCases: Array<{ text: string; o: Record<string, unknown> }> = []
shapes.forEach((shape, i) => {
  badgeCases.push({ text: 'Top pick', o: { shape } })
  badgeCases.push({ text: 'New', o: { shape, color: 'sky', sub: 'just in', deco: decos[i % decos.length], textColor: 'ink-you', bumps: 10 + i, amp: 2.4 } })
})
badgeCases.push({ text: 'Sale', o: { fill: 'lemon~', deco: 'percent', tags: ['deal'] } })
badgeCases.push({ text: 'Default', o: {} })
const badges = badgeCases.map((c) => ({ ...c, def: badgeSkeleton(c.text, c.o as never) }))
const badgeDies = badgeCases.map((c, i) => ({ i, size: i % 4 ? 72 : 112, seed: `badge${i}`, out: out(dieCut(badges[i].def, i % 4 ? 72 : 112, `badge${i}`, {})) }))

const stampCases: Array<{ text: string; shape: StampGen['shape']; o: Record<string, unknown> }> = [
  { text: 'Approved', shape: 'rect', o: {} },
  { text: 'Approved', shape: 'rect', o: { seed: 7, tilt: 0, sub: 'checked', ink: 'green', ghost: true } },
  { text: 'Draft', shape: 'rect', o: { dashed: true, w: 120, h: 48, seed: 'x' } },
  { text: 'Paid', shape: 'round', o: { ring: 'PAID IN FULL * THANK YOU', stars: 1 } },
  { text: 'Ok', shape: 'round', o: { ring: 'A B', sub: 'sub', w: 80, ink: 'ink' } },
  { text: 'New', shape: 'burst', o: {} },
  { text: 'New', shape: 'burst', o: { stars: 2, sub: 'fresh', w: 120 } },
  { text: 'Void', shape: 'void', o: {} },
  { text: 'Cancelled', shape: 'void', o: { h: 50, ink: 'ink-you', grain: false } },
]
const stamps = stampCases.map((c) => ({ ...c, out: out(stamp(c.text, c.shape, c.o as never)) }))

const meta = {
  variants: (['icon', 'doodle', 'sticker', 'mascot', 'prop', 'scene'] as const).flatMap((kind) =>
    [8, 13, 13.5, 19, 20, 39.9, 40, 41, 71, 72, 79, 80, 119, 120, 139, 140].map((size) => ({ kind, size, out: variantFor(kind, size) })),
  ),
  mascotVariants: [10, 27.9, 28, 55, 56, 139, 140, 300].map((size) => ({ size, out: mascotVariant(size) })),
  partCounts: Object.entries(icons).slice(0, 12).map(([id, def]) => ({ id, out: (['micro', 'small', 'master', 'hi'] as const).map((v) => partsFor(def as ArtDef, v).length) })),
  kinds: [
    { grid: 24, out: kindOfDef({ grid: 24 }) },
    { grid: 64, out: kindOfDef({ grid: 64 }) },
    { grid: [64, 72], out: kindOfDef({ grid: [64, 72] }) },
  ],
  names: ['LucideArrowRight', 'ArrowRightIcon', 'AlertCircle', 'Trash2', 'BarChart3', 'MoreHorizontal', 'home', 'File_Text icon', 'XMLParser', 'Grid3x3'].map((name) => ({
    name,
    kebab: kebabIconName(name),
    out: resolveIconName(name),
  })),
  ids: {
    icons: Object.keys(icons),
    iconBatches: Object.fromEntries(Object.entries(iconBatches).map(([k, v]) => [k, Object.keys(v)])),
    doodles: Object.keys(doodles),
    stickers: Object.keys(stickers),
    stickerBatches: Object.fromEntries(Object.entries(stickerBatches).map(([k, v]) => [k, Object.keys(v)])),
    mascot: Object.keys(mascot),
    mascotProps: Object.keys(mascotProps.propDefs),
    mascotFrames: Object.keys(mascotProps.frames),
    scenes: Object.keys(scenes),
  },
}

// Validation: every catalog definition (with the glyph lookup), crafted bad definitions and paths.
const catalogs: Array<[string, Record<string, unknown>]> = [
  ['icons', icons], ['doodles', doodles], ['stickers', stickers], ['mascot', mascot],
  ['props', mascotProps.propDefs], ['frames', mascotProps.frames], ['scenes', scenes],
]
const catalogProblems = catalogs.flatMap(([table, defs]) =>
  Object.entries(defs)
    .filter(([, def]) => !('gen' in (def as object)))
    .map(([id, def]) => ({ table, id, out: validateArt(def as ArtDef, { glyph: hasGlyph }) }))
    .filter((c) => c.out.length),
)
const bad: Array<{ def: ArtDef; kind?: string }> = [
  { def: { grid: 24, parts: [] } },
  { def: { grid: [4, 600], parts: [['s', 'M1 1 L5 5', 2]], nibK: 0.5, tags: ['', 'ok'] } },
  { def: { grid: 24, parts: [['f', 'acc', 'M1 1 L30 1 L30 30 Z', 4], ['c', 'sil', 'M3 3 L9 9', 0.5], ['d', 30, 1, 9], ['d', 5, 5, 0.2], ['t', 'H~I', 12, 12, 4, 'ink', 'type'], ['h', 'X1 2']] } },
  { def: { grid: 64, parts: [['s', 'M10 10 L20 20 L10 10.1 Q', 1.6], ['s', 'L1 1 Z 3', 1], ['s', 'O 10 10 -2 M1', 1], ['s', 'E 5 5 0 2 0 9 Z', 1]] }, kind: 'doodle' },
  { def: { grid: 64, parts: [['s', 'M10 10 L20 20 L30 30 L40 40 L50 50 L20 20 L10 10'], ['s', 'M10.123 10 L20.555 20']], small: [['s', 'M10 10 L20 20 L30 30 L40 40 L50 50 L20 20 L10 10'], ['s', 'M10.123 10 L20.555 20']] } },
  { def: { grid: 24, parts: Array.from({ length: 8 }, () => ['s', 'M4.2 4.4 L8.1 8.3'] as const), micro: Array.from({ length: 10 }, (_, i) => ['d', 5 + i, 6, 1] as const), hi: [['s', 'M4.2 4.4 L8.1 8.3', 1.5]] } },
  { def: { grid: [64, 72], parts: [['f', 'sil', 'M-9 -9 L99 -9 L99 99 Z'], ['c', 'sky~', 'M2 2 L70 80', 1.45], ['t', 'Hi', 30, 40, 6]] } },
]
const validation = {
  catalog: catalogProblems,
  bad: bad.map((c) => ({ ...c, out: validateArt(c.def, { kind: c.kind as never, glyph: hasGlyph }) })),
  paths: ['', '   ', 'M1 1 L2', 'L1 1', 'M1 1 Z', 'M1 1 L2 2 L3 1 Z 4', 'O 1 1', 'O 1 1 0', 'O 1 1 2 -1', 'E 1 1 2 2 0', 'E 1 1 -2 2 0 9', 'M1 1 Q1 2 3', 'M1 1 C1 2 3 4 5', '5 M1 1 L2 2', 'M1 1 L2 2 # ?', 'M10 10 L20 10 L20 20 L10.1 10.1', 'M1.234 1 L2 2', 'M1 1 L2 2 L3 3 L4 4', 'O 12 12 6 E 5 5 2 2 0 90 L1 1', 'M2 2 l3 4 5 6 Z'].map((d) => ({ d, out: checkPath(d) })),
}

writeChunks('art_core', badgeDies, { dsl, text, badges, stamps, meta, validation })

// Icons: every variant in the ui tone, and doodle-toned with accents at one size.
const iconIds = Object.keys(icons)
const iconCase = (id: string, size: number, o: DrawOpts, tag: string) => ({ id, size, seed: `${tag}:${id}`, o, out: out(drawSkeleton((icons as Record<string, ArtDef>)[id], size, `${tag}:${id}`, o)) })
const iconChunk = (ids: string[]) =>
  ids.flatMap((id, i) => [
    iconCase(id, 12, {}, 'i12'),
    iconCase(id, 16, {}, 'i16'),
    iconCase(id, 24, {}, 'i24'),
    iconCase(id, 48, i % 3 ? {} : { tier: 'hi' }, 'i48'),
    ...(i % 3 ? [] : [iconCase(id, 32, { tone: 'doodle', accent: (['tomato', 'sky', 'lemon', 'grape'] as const)[i % 4], crisp: i % 2 === 0, calm: i % 5 === 0 }, 'id32')]),
  ])
writeChunks('art_icons', iconChunk(iconIds))

// Doodles: small, master and hi (which switches to the hi tier at 128).
const doodleIds = Object.keys(doodles)
const doodleCase = (id: string, size: number, o: DrawOpts, tag: string) => ({ id, size, seed: `${tag}:${id}`, o, out: out(drawSkeleton((doodles as Record<string, ArtDef>)[id], size, `${tag}:${id}`, o)) })
writeChunks(
  'art_doodles',
  doodleIds.flatMap((id, i) => [
    doodleCase(id, 48, {}, 'd48'),
    doodleCase(id, 96, i % 4 ? {} : { ink: 'ink-you', grain: false }, 'd96'),
    ...(i % 3 === 0 ? [doodleCase(id, 128, {}, 'd128')] : []),
  ]),
)

// Stickers: through renderSticker, small and master, some with shadow and peel.
const stickerCase = (id: string, size: number, o: DieCutOpts, tag: string) => ({ id, size, seed: `${tag}:${id}`, o, out: out(renderSticker((stickers as Record<string, ArtDef | BadgeGen | StampGen>)[id], size, `${tag}:${id}`, o) as never) })
writeChunks(
  'art_stickers',
  Object.keys(stickers).flatMap((id, i) => [
    stickerCase(id, 64, {}, 's64'),
    stickerCase(id, 96, [{}, { shadow: true }, { peel: true }, { peel: 14, shadow: true, tier: 'lo' }][i % 4] as DieCutOpts, 's96'),
  ]),
)

// The mascot: every pose, prop and frame through drawMascot, and a pose through drawSkeleton.
const mascotCase = (table: string, id: string, def: ArtDef, size: number, o: Record<string, unknown>) => ({ table, id, size, seed: `m${size}:${id}`, o, out: out(drawMascot(def, size, `m${size}:${id}`, o)) })
const tables: Array<[string, Record<string, ArtDef>]> = [['mascot', mascot as Record<string, ArtDef>], ['props', mascotProps.propDefs as Record<string, ArtDef>], ['frames', mascotProps.frames as Record<string, ArtDef>]]
writeChunks(
  'art_mascot',
  tables.flatMap(([table, defs]) =>
    Object.entries(defs).flatMap(([id, def], i) => [
      mascotCase(table, id, def, 24, {}),
      mascotCase(table, id, def, 48.4, i % 2 ? {} : { shadow: true }),
      mascotCase(table, id, def, 96, table === 'mascot' && i % 3 === 0 ? { tier: 'hi', idPrefix: `pfx-${id}` } : {}),
      ...(table === 'mascot' ? [mascotCase(table, id, def, 160, i % 4 === 0 ? { border: 3 } : {})] : []),
    ]),
  ),
  { skeletons: Object.entries(mascot).slice(0, 5).map(([id, def]) => ({ id, size: 72, seed: `sk:${id}`, out: out(drawSkeleton(def as ArtDef, 72, `sk:${id}`)) })) },
)

// Scenes: their own parts, drawn as scenes.
writeChunks(
  'art_scenes',
  Object.entries(scenes).flatMap(([id, def]) => [
    { id, size: 240, seed: `sc:${id}`, out: out(drawSkeleton(def as ArtDef, 240, `sc:${id}`)) },
    { id, size: 120, seed: `sc120:${id}`, out: out(drawSkeleton(def as ArtDef, 120, `sc120:${id}`, { tier: 'hi' })) },
  ]),
)
