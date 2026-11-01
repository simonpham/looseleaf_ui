// V8's Math.* on a spread of inputs, for packages/looseleaf_ink/test/js_math_test.dart (the fdlibm port in JsMath).
import { writeFixture } from '../write'

let s = 12345
const r = () => {
  s = (s * 1103515245 + 12345) % 2147483648
  return s / 2147483648
}
const scales = [1e-9, 1e-3, 1, 10, 1000, 4e4]
const pick = (i: number) => scales[i % scales.length]
const N = 600
const sample = <T>(f: (i: number) => T) => Array.from({ length: N }, (_, i) => f(i))

const edge = [0, 0.5, -0.5, 1, -1, Math.PI / 4, Math.PI / 2, Math.PI, 2 * Math.PI, 3 * Math.PI / 4, 1e-300, 700, -740, 709.78, 2.4375, 0.4375]
const sin = [...edge, ...sample((i) => (r() - 0.5) * 20 * pick(i))].map((x) => [x, Math.sin(x)])
const cos = [...edge, ...sample((i) => (r() - 0.5) * 20 * pick(i))].map((x) => [x, Math.cos(x)])
const exp = [...edge, ...sample((i) => (r() - 0.5) * 60 / Math.sqrt(pick(i) + 1))].map((x) => [x, Math.exp(x)])
const log = [...edge.filter((x) => x > 0), 1e-310, ...sample((i) => r() * 50 * pick(i))].map((x) => [x, Math.log(x)])
const atan = [...edge, 1e20, -1e20, ...sample((i) => (r() - 0.5) * 20 * pick(i))].map((x) => [x, Math.atan(x)])
const atan2 = [...[[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [2, 1e-20], [1e-20, -2], [-3, -4]], ...sample((i) => [(r() - 0.5) * 20 * pick(i), (r() - 0.5) * 20 * pick(i + 3)])].map(([y, x]) => [y, x, Math.atan2(y, x)])
const hypot = [...[[0, 0], [3, 4], [-0, 5], [1e-300, 1e-300], [1e300, 1e300]], ...sample((i) => [(r() - 0.5) * 20 * pick(i), (r() - 0.5) * 20 * pick(i + 2)])].map(([a, b]) => [a, b, Math.hypot(a, b)])
const pow = sample((i) => [r() * 3, [0.5, 2, 0.75, 1.2, 1, -1][i % 6]]).map(([x, y]) => [x, y, Math.pow(x, y)])
const round = [0.5, -0.5, 1.5, -1.5, 2.4999999999999996, 0.49999999999999994, -0.49999999999999994, 1e16 + 1, -2.5, 3.7, -3.7].map((x) => [x, Math.round(x)])
const strings = [0, 1, -1, 0.1, 1.5, -2.25, 1e21, 1e-7, 123456789.125, 1 / 3, 2 ** 53, 5e-324].map((x) => [x, String(x)])
const fixed = [0, 1.005, 2.675, -0.001, 1.25, 123.456, 1e-7, -2.5].map((x) => [x, x.toFixed(2)])

writeFixture('packages/looseleaf_ink/test/fixtures/js_math.json', { sin, cos, exp, log, atan, atan2, hypot, pow, round, strings, fixed })
