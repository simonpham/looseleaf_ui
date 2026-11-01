# Parity fixtures

The ink engine is a faithful port of [Looseleaf](https://github.com/kevintngo/looseleaf)'s `src/lib/ink`. These exporters run the original TypeScript and save its output as JSON fixtures; the Dart tests draw the same inputs and compare.

```sh
git clone --depth 1 https://github.com/kevintngo/looseleaf .upstream/looseleaf
tools/parity/export.sh .upstream/looseleaf            # every exporter
tools/parity/export.sh .upstream/looseleaf rng pen    # some of them
```

Fixtures were last exported from upstream commit `747ba9f`.

Each exporter in `exporters/` imports the original through its `@/` alias and calls `writeFixture` (`write.ts`) with a path under the repo root.
