// CSS url() tiles from pencil-tiles-ink.ts, for packages/looseleaf_ink/test/pencil_tiles_test.dart.
import { circleTile, edgeTile, hatchTile } from '@/lib/ink/recipes/pencil-tiles-ink'
import { writeFixture } from '../write'

const seeds = ['a', 'tile-1', 'll-skeleton']
writeFixture('packages/looseleaf_ink/test/fixtures/pencil_tiles.json', {
  edge: seeds.flatMap((seed) => [false, true].map((vertical) => ({ seed, vertical, out: edgeTile(seed, vertical) }))),
  hatch: seeds.map((seed) => ({ seed, out: hatchTile(seed) })),
  circle: seeds.map((seed) => ({ seed, out: circleTile(seed) })),
})
