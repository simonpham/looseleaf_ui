// rng streams, hashSeed, noise and number formatting, for packages/looseleaf_ink/test/core_test.dart.
import { hashSeed, makeRng, type Rng } from '@/lib/ink/rng'
import { noise1, wander } from '@/lib/ink/noise'
import { esc, fmtUnits, n, paint, PAINT_KEYS, type Q } from '@/lib/ink/paint'
import { writeFixture } from '../write'

const seeds: Array<string | number> = ['', 'a', 'button|button', 'll-seed', 'ünïcødé ✓', 0, 1, 42, -7, 3.75, 4294967296, 1e21, 0x9e3779b9]

const stream = (r: Rng, count: number) => Array.from({ length: count }, () => r())

const rng = seeds.map((seed) => {
  const r = makeRng(seed)
  const plain = stream(r, 8)
  const range = [r.range(-3, 5), r.range(0.42, 0.6)]
  const ints = [r.int(3, 7), r.int(-2, 2), r.int(0, 100)]
  const chances = [r.chance(0.5), r.chance(0.1), r.chance(0.9)]
  const signs = [r.sign(), r.sign(), r.sign()]
  const picks = [r.pick(['a', 'b', 'c', 'd']), r.pick([1, 2, 3])]
  const gauss = [r.gauss(), r.gauss(), r.gauss(2, 0.5), r.gauss(0, 0.012), r.gauss()]
  const after = stream(r, 3)
  const forks = ['noise', 'end', 's:0', 7, 2.5, 'layers'].map((name) => ({ name, values: stream(r.fork(name), 4) }))
  const nested = stream(r.fork('a').fork('b').fork(3), 4)
  return { seed, hashed: hashSeed(seed), plain, range, ints, chances, signs, picks, gauss, after, forks, nested }
})

const hashes = ['', 'x', 'focus', 'M1 2l3 4z', 'button|button|focus', 12, 0, -1, 2.9, -2.9, 1e10, NaN, Infinity].map((s) => ({
  input: typeof s === 'number' && !Number.isFinite(s) ? String(s) : s,
  hash: hashSeed(s),
}))

const noise = [
  { seed: 'n1', length: 120, wavelength: 9 },
  { seed: 'n2', length: 30, wavelength: 80 },
  { seed: 'n3', length: 400, wavelength: 4.5 },
  { seed: 'n4', length: 0, wavelength: 55 },
].map(({ seed, length, wavelength }) => {
  const f = noise1(makeRng(seed), length, wavelength)
  const at = [-5, 0, 0.3, 1, 2.5, 7.7, 13, 29.9, 30, 55, 119.5, 200, 1000]
  return { seed, length, wavelength, at, values: at.map(f) }
})

const wanders = [
  { seed: 'w1', periods: [37, 11] },
  { seed: 'w2', periods: [53, 17, 5] },
].map(({ seed, periods }) => {
  const f = wander(makeRng(seed), ...periods)
  const at = [0, 1, 7.3, 50, 123.4]
  return { seed, periods, at, values: at.map(f) }
})

const values = [0, -0, 1, -1, 0.05, 0.025, -0.025, 0.075, 1.234, -1.234, 12.345, 0.5, -0.5, 99.999, 1e-9, 123456.789, 0.35, 2.675, -2.675, NaN, Infinity]
const formats = values.map((v) => ({
  v: Number.isFinite(v) ? v : String(v),
  q10: n(v, 10),
  q20: n(v),
  q100: n(v, 100),
}))
const units = [0, 1, -1, 5, 10, 15, 20, 25, 99, 100, 101, 105, -105, 1234].flatMap((k) => ([10, 20, 100] as Q[]).map((q) => ({ k, q, s: fmtUnits(k, q) })))

writeFixture('packages/looseleaf_ink/test/fixtures/core.json', {
  rng,
  hashes,
  noise,
  wanders,
  formats,
  units,
  paints: PAINT_KEYS.map((k) => ({ key: k, css: paint(k) })),
  escapes: ['plain', `a & b < c > "d" 'e'`, '&amp;'].map((s) => ({ s, out: esc(s) })),
})
