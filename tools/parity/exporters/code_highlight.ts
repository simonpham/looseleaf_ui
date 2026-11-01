// The code block's lexer (src/lib/code-highlight.ts): tokens per language over hand-picked snippets and
// real files of the upstream checkout, diff parsing and language lookup, for
// packages/looseleaf_ui/test/components/code_block/code_highlight_test.dart.
import { readFileSync } from 'node:fs'

import { diffResult, diffStats, langFromFileName, normaliseLang, parseDiff, tokenize, tokenizeLines, type Lang } from '@/lib/code-highlight'
import { writeFixture } from '../write'

const snippets: Array<[string, Lang, string]> = [
  [
    'tsx docs',
    'tsx',
    `import { useState } from "react"

type Props = { tags: string[] } // one per note

export function TagChips({ tags }: Props) {
  const [on, setOn] = useState(new Set<string>())
  return (
    <ul className="flex gap-2">
      {tags.map((t) => (
        <li key={t}>{t}</li>
      ))}
    </ul>
  )
}`,
  ],
  ['ts generics', 'ts', 'const a = f<T>(x) ?? y?.z; let n = 0x1F_ff + 1_000.5e-3 + .5 + 10n; obj.class = new Foo(); a ??= b >>>= 2'],
  ['ts template', 'ts', 'const s = `a ${b + `c ${d}`} e` + \'x\\\'y\' + "unterminated\nnext /* c */ /* open'],
  ['tsx nested', 'tsx', 'const el = cond && <Box a="1" b={x > 1 ? <i/> : null} {...rest}>text {v} <b>bold</b> < 3</Box>;\nreturn <><A.B c-d=\'e\' /></>'],
  ['jsx compare', 'jsx', 'if (a < b) { x = a<b }\nconst y = (<div>{a}</div>)'],
  ['js plain', 'js', '// line\nfunction add(a, b) { return a + b } /* block */ const r = /x/g; label: for (;;) {}\n@dec #priv \\ ~'],
  ['css', 'css', `@media (min-width: 40rem) {
  .card > h1 {
    color: var(--ll-ink); /* felt */
    margin: -2px 1.5rem !important;
    background: #fff url("a.png") rgba(0, 0, 0, .5);
    --my-var: 12px;
  }
}
a:hover, *::before { content: 'x' }`],
  ['json', 'json', '{\n  "name": "looseleaf",\n  "private": true,\n  "keywords": ["paper", null],\n  "n": -1.5e+3, // c\n  /* b */ "x" : false\n}'],
  ['bash', 'bash', `$ npx shadcn add https://kevintngo.github.io/looseleaf/r/bubble.json --overwrite
# then draw something
export FOO=$BAR && echo "\${FOO}" | grep -i tags > out.txt 2>&1
for f in *.ts; do echo $1 \${f} 42; done; a#b
> continued --flag=1 -x`],
  ['text', 'text', 'just\nplain text'],
  ['empty', 'ts', ''],
]

const files: Array<[string, Lang, number?]> = [
  ['src/components/ui/code-block.tsx', 'tsx'],
  ['src/lib/code-highlight.ts', 'ts'],
  ['src/styles/looseleaf.css', 'css', 200],
  ['package.json', 'json'],
]

const compact = (tokens: Array<{ type: string; text: string }>) => tokens.map((t) => [t.type, t.text])

const tokenCases = [
  ...snippets.map(([name, lang, code]) => ({ name, lang, code })),
  ...files.map(([path, lang, lines]) => {
    const all = readFileSync(path, 'utf8')
    return { name: path, lang, code: lines ? all.split('\n').slice(0, lines).join('\n') : all }
  }),
].map((c, i) => ({
  ...c,
  tokens: i < snippets.length ? compact(tokenize(c.code, c.lang)) : undefined,
  lines: tokenizeLines(c.code, c.lang).map(compact),
}))

const diffs = [
  `-const shown = notes;
+const shown = picked.size
+  ? notes.filter((n) => picked.has(n.tag))
+  : notes;
 export const count = shown.length;
-export const label = "all";
+export const label = picked.size ? "filtered" : "all";`,
  `diff --git a/x.ts b/x.ts
index 1a2b3c..4d5e6f 100644
--- a/x.ts
+++ b/x.ts
@@ -1,3 +1,3 @@
 keep
-old
+new
plain
\\ No newline at end of file
`,
  '--- /dev/null\n+++ b/new.ts\n+only\n',
  '',
]

const diffCases = diffs.map((code) => {
  const rows = parseDiff(code)
  return { code, rows, result: diffResult(rows), stats: diffStats(rows) }
})

const langs = ['tsx', 'TS', 'typescript', 'Javascript', 'mjs', 'cjs', 'scss', 'jsonc', 'sh', 'zsh', 'console', 'patch', 'html', 'txt', 'rust', '', 'Diff']
const fileNames = ['a.tsx', 'b.d.ts', 'Makefile', 'x.SH', '.zshrc', 'card.css', 'package.json', 'notes.md', 'a.b.c.patch']

writeFixture('packages/looseleaf_ui/test/fixtures/code_highlight.json', {
  tokens: tokenCases,
  diffs: diffCases,
  langs: langs.map((l) => [l, normaliseLang(l)]),
  undefinedLang: normaliseLang(undefined),
  fileNames: fileNames.map((f) => [f, langFromFileName(f)]),
})
