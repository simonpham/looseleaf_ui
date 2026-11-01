// Shared helpers for the exporters/ink_charts* exporters: JSON-safe layouts with their cursors, hits and key steps.
import { hitIndex, stepIndex } from '@/lib/ink/charts/chart-layout'
import type { ChartLayoutBase } from '@/lib/ink/charts/chart-types'

/** Drops functions and null/undefined/non-finite object values; non-finite numbers in arrays become null. */
export function clean(v: unknown): unknown {
  if (typeof v === 'number') return Number.isFinite(v) ? v : null
  if (Array.isArray(v)) return v.map(clean)
  if (v && typeof v === 'object') {
    const out: Record<string, unknown> = {}
    for (const [k, x] of Object.entries(v)) {
      if (typeof x === 'function') continue
      const c = clean(x)
      if (c === null || c === undefined) continue
      out[k] = c
    }
    return out
  }
  return v
}

const KEYS = ['Home', 'End', 'ArrowRight', 'ArrowLeft', 'ArrowDown', 'ArrowUp', 'PageDown', 'PageUp', 'Enter']

/** A layout with its cursors (per target, and for series 0), hit tests over a grid, and key steps. */
export function dumpLayout(l: ChartLayoutBase, series = false): unknown {
  const n = l.targets.n
  const idx = [-1, ...Array.from({ length: Math.min(n, 40) }, (_, i) => i), n]
  const hits: Array<number | null> = []
  for (let gy = 0; gy <= 8; gy++) for (let gx = 0; gx <= 10; gx++) hits.push(hitIndex(l.targets, (l.w * gx) / 10, (l.h * gy) / 8))
  const steps = KEYS.map((key) => [null, -1, 0, 1, Math.floor(n / 2), n - 1, n].map((from) => stepIndex(l.targets, from, key)))
  return clean({
    ...l,
    cursors: idx.map((i) => l.cursorAt(i)),
    ...(series ? { cursors0: idx.map((i) => l.cursorAt(i, 0)) } : {}),
    hits,
    steps,
  })
}

/** An input number for a fixture: non-finite values as `'NaN'`, `'Infinity'` or `'-Infinity'`. */
export const enc = (v: unknown): unknown => (typeof v === 'number' && !Number.isFinite(v) ? String(v) : Array.isArray(v) ? v.map(enc) : v)
