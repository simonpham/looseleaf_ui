// Sticker faces and their kiss cuts, labels and the catalog from sticker-ink.ts,
// for packages/looseleaf_ink/test/sticker_test.dart.
import { categoryLabel, hasSticker, kissCut, stickerCatalog, stickerFace, stickerLabel, type FaceOpts } from '@/lib/ink/recipes/sticker-ink'
import { writeFixture } from '../write'

const labels = ['cat-loaf', 'hand_point__right', '  -wip-  ', '', 'a', 'stamp-approved'].map((name) => ({ name, out: stickerLabel(name) }))
const categories = ['statusPointers', 'badgesStamps', 'myNewBatch', 'x2Y', 'plain'].map((key) => ({ key, out: categoryLabel(key) }))
const has = ['smiley', 'stamp-paid', 'nope', 'toString', ''].map((name) => ({ name, out: hasSticker(name) }))

const faceCases: Array<{ name: string; px: number; seed: string; o?: FaceOpts }> = [
  { name: 'smiley', px: 96, seed: 'a' },
  { name: 'smiley', px: 20, seed: 'a' },
  { name: 'cat-loaf', px: 64.4, seed: 'b', o: { peel: true } },
  { name: 'rocket', px: 120, seed: 'c', o: { peel: 14, border: 5 } },
  { name: 'done', px: 72, seed: 'd', o: { peel: 0, idPrefix: 'll-x0' } },
  { name: 'pizza-slice', px: 48, seed: 'e', o: { border: 3.5 } },
  { name: 'stamp-approved', px: 96, seed: 'f' },
  { name: 'stamp-paid', px: 64, seed: 'g', o: { peel: true, idPrefix: 'p' } },
  { name: 'first-place', px: 80, seed: 'h' },
  { name: 'notebook', px: 140, seed: 'i', o: { peel: false } },
  { name: 'missing', px: 64, seed: 'j' },
]
const faces = faceCases.map((c) => {
  const face = stickerFace(c.name, c.px, c.seed, c.o)
  return { ...c, o: c.o ?? {}, out: face, kiss: face ? kissCut(face, `k-${c.seed}`) : null }
})

writeFixture('packages/looseleaf_ink/test/fixtures/sticker.json', { labels, categories, has, catalog: stickerCatalog(), faces })
