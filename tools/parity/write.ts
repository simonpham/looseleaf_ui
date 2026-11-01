import { mkdirSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'

/** Writes a fixture as JSON under the repo root, e.g. `packages/looseleaf_ink/test/fixtures/rng.json`. */
export function writeFixture(relativePath: string, data: unknown): void {
  const root = process.env.LOOSELEAF_UI_ROOT
  if (!root) throw new Error('LOOSELEAF_UI_ROOT is not set; run through export.sh')
  const file = join(root, relativePath)
  mkdirSync(dirname(file), { recursive: true })
  writeFileSync(file, JSON.stringify(data, null, 1) + '\n')
  console.log(`    ${relativePath}`)
}
