// Ink builder scenarios (layers, groups, parts, defs, clips, text, lean merging, knobs), for
// packages/looseleaf_ink/test/builder_test.dart. Each scenario is mirrored by name in the Dart test.
import { Ink, inkViewBox, maskId, maskPhase, MASK_IDS, type InkOptions } from '@/lib/ink/builder'
import { grainMaskId, grainMaskUrl, grainPhase, grainVariantFor } from '@/lib/ink/textures'
import { roundRectPoly } from '@/lib/ink/geom'
import { box, focusRing, underline } from '@/lib/ink/shapes'
import { bandFill, blobFill, highlight, wash } from '@/lib/ink/fills'
import type { LayerName, Pt } from '@/lib/ink/types'
import { writeFixture } from '../write'

const body = roundRectPoly(0.5, 0.5, 119, 35, 4)
const curve: Pt[] = [[4, 30], [40, 8], [80, 28], [116, 6]]

const scenarios: Record<string, { opts: InkOptions; draw: (ink: Ink) => void; layers?: LayerName[]; pad?: number }> = {
  layers: {
    opts: {},
    draw: (ink) => {
      box(ink, 0, 0, 120, 36)
      ink.layer('hover', () => wash(ink, body, 'hi', { alpha: 0.5 }))
      ink.layer('focus', () => focusRing(ink, 0, 0, 120, 36, { r: 4 }))
      ink.layer('disabled', () => ink.poly('under', body, 'paper-shade', 0.9))
    },
  },
  filtered: {
    opts: { tier: 'hi' },
    layers: ['hover', 'rest'],
    pad: 7,
    draw: (ink) => {
      ink.layer('hover', () => highlight(ink, 6, 8, 108, 20, { k: 1 }))
      box(ink, 0, 0, 120, 36, { pen: 'pencil.fine' })
      ink.layer('pressed', () => box(ink, 0, 0, 120, 36))
    },
  },
  parts: {
    opts: {},
    draw: (ink) => {
      ink.lean()
      ink.part('fill', () => bandFill(ink, body, 'marker', { passes: 2, alpha: 0.84 }))
      ink.part('fill2', () => wash(ink, body, 'hi', { alpha: 0.5 }), 'marker')
      ink.part('swipe', () => highlight(ink, 6, 8, 108, 20, { k: 1 }), 'hl')
      ink.part('under', () => underline(ink, 10, 30, 100, { pen: 'blue.fine', kind: 'single' }), 'top')
      box(ink, 0, 0, 120, 36)
    },
  },
  leanSmall: {
    opts: { tier: 'hi' },
    draw: (ink) => {
      ink.lean()
      ink.part('fill', () => blobFill(ink, body, 'red', { alpha: 0.97 }))
      box(ink, 0, 0, 120, 36, { pen: 'redfelt' })
      ink.stroke(curve, 'pencil')
      ink.stroke(curve, 'm_lemon')
    },
  },
  groups: {
    opts: {},
    draw: (ink) => {
      const clip = ink.clipDef('M0 0h120v36H0z')
      ink.group({ transform: 'translate(3 4)', opacity: 0.5, id: 'g<1>', clip: 'M0 0h60v36H0z', hideOn: 'hover', mask: 'm1' }, () => {
        ink.stroke(curve, 'ink')
        ink.flat('marker', 'M0 0h10v10z', 'marker', 0.4, { clip })
      })
      ink.group({ part: 'plain', vars: { a: 1.234, b: -0.5 } }, () => ink.stroke(curve, 'blue.fine'), 'felt')
      ink.group({ opacity: 1 }, () => ink.dot(20, 20, 3, 'ink'))
    },
  },
  defs: {
    opts: { tier: 'hi' },
    draw: (ink) => {
      const id = ink.define(() => {
        ink.stroke([[0, 0], [10, 6]], 'ink.fine')
        ink.dot(5, 5, 2, 'pencil')
      })
      ink.use(id, { x: 10, y: 0 })
      ink.use(id, { x: 0, y: 12.35, transform: 'rotate(45)' }, 'felt')
      ink.use(ink.define(() => ink.raw('<circle r="2"/>')))
    },
  },
  flats: {
    opts: {},
    draw: (ink) => {
      ink.flat('felt', 'M0 0L10 10', 'ink', 0.8, { stroke: 'ink', sw: 1.25, bbox: [0, 0, 10, 10] })
      ink.flat('felt', 'M2 2L12 12', 'ink', 1, { stroke: 'red' })
      ink.flat('marker', 'M0 0h5v5z', 'marker', 0.5, { rule: 'evenodd' })
      ink.flat('marker', 'M0 0h6v6z', 'marker', 0.502)
      ink.flat('marker', 'M1 1h6v6z', 'marker', 0.499)
      ink.flat('marker', '', 'marker', 0.5)
      ink.poly('wash', [[0, 0], [1, 1]], 'hi')
      ink.raw('')
      ink.raw('<rect width="3" height="3"/>', 'stamp')
      ink.text(10, 20, `Hi & <bye> "x" 'y'`, { size: 14.5, fill: 'ink-soft', anchor: 'middle', weight: 600 })
      ink.text(0, 0, 'plain')
      ink.text(5, 5, 'font', { size: 12, font: 'Kevin "Sans"' })
    },
  },
  calm: {
    opts: { calm: true, tier: 'hi', knobs: { wobble: 2, misreg: 3, bleed: 1.5, width: 1.2 } },
    draw: (ink) => {
      wash(ink, body, 'marker', { alpha: 0.32 })
      box(ink, 0, 0, 120, 36)
      ink.dot(10, 10, 2)
    },
  },
  knobs: {
    opts: { tier: 'hi', knobs: { wobble: 0.5, misreg: 2, bleed: 1.6, width: 1.3 } },
    draw: (ink) => {
      wash(ink, body, 'hi')
      ink.lines([{ pts: curve, o: { width: 2, alpha: 0.5 } }, { pts: curve.map(([x, y]) => [x, y + 6] as Pt), pen: 'red' }], 'blue', { width: 0.5, alpha: 0.8, simple: true })
      ink.lines([{ pts: curve }], 'pencil')
      ink.dot(30, 30, 3, 'blue', { width: 2 })
    },
  },
  noGrain: {
    opts: { grain: false, tier: 'hi' },
    draw: (ink) => {
      ink.lean()
      wash(ink, body, 'hi')
      box(ink, 0, 0, 120, 36)
      ink.stroke(curve, 'pencil')
      ink.stroke(curve, 'red')
      ink.stroke(curve, 'hi')
    },
  },
  empty: { opts: {}, draw: () => {} },
}

const out = Object.entries(scenarios).map(([name, s]) => {
  const ink = new Ink(`builder-${name}`, s.opts)
  s.draw(ink)
  const res = ink.toSvg({ w: 120, h: 36, pad: s.pad, layers: s.layers })
  return {
    name,
    seed: ink.seed,
    variant: ink.variant,
    tier: ink.tier,
    knobs: ink.knobs,
    svg: res.svg,
    pad: res.pad,
    layers: res.layers,
    parts: res.parts,
    bbox: res.bbox,
    viewBox: inkViewBox(res),
  }
})

writeFixture('packages/looseleaf_ink/test/fixtures/builder.json', {
  scenarios: out,
  masks: {
    ids: MASK_IDS,
    wrapped: [-7, -1, 0, 5, 6, 13].map((v) => maskId('felt', v)),
    phases: [0, 1, 2, 3, 4, 5, 7, -2].map((v) => ({ v, phase: maskPhase(v), grain: grainPhase(v) })),
    grainIds: [grainMaskId('marker'), grainMaskId('waxy', 8), grainMaskId('stamp', -1, 'x'), grainMaskUrl('felt', 2)],
    variants: [0, 1, 42, 0x9e3779b9, 4294967295, 123456789].map((seed) => grainVariantFor(seed)),
  },
})
