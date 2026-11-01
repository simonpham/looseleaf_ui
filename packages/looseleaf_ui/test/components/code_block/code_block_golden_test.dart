import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/ibm_plex_mono.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

const _tsx = '''import { useState } from "react"

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
}''';

const _patch = '''-const shown = notes;
+const shown = picked.size
+  ? notes.filter((n) => picked.has(n.tag))
+  : notes;
 export const count = shown.length;
-export const label = "all";
+export const label = picked.size ? "filtered" : "all";''';

const _css = '''@media (min-width: 40rem) {
  .card > h1 {
    color: var(--ll-ink); /* felt */
    margin: -2px 1.5rem !important;
  }
}''';

const _json =
    '{\n  "name": "looseleaf",\n  "private": true,\n  "keywords": ["paper", null]\n}';

const _bash = r'''$ npx shadcn add https://kevintngo.github.io/looseleaf/r/bubble.json https://kevintngo.github.io/looseleaf/r/message.json --overwrite
# then draw something
export FOO=$BAR && echo "${FOO}" | grep -i tags''';

Widget _column(List<Widget> children) => SizedBox(
  width: 576,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d40,
    children: children,
  ),
);

Widget _default() => _column(const [
  CodeBlock(
    code: _tsx,
    filename: 'src/notes/tag-chips.tsx',
    lineNumbers: true,
    seed: 'default',
  ),
]);

Widget _diff() => _column(const [
  CodeBlock(
    diff: true,
    code: _patch,
    language: 'ts',
    filename: 'src/notes/filter.ts',
    lineNumbers: true,
    seed: 'diff',
  ),
  CodeBlock(
    diff: true,
    code: _patch,
    language: 'ts',
    filename: 'filter.ts',
    tone: CodeBlockTone.paper,
    seed: 'chat',
  ),
]);

Widget _languages() => _column(const [
  CodeBlock(filename: 'card.css', seed: 'css', code: _css),
  CodeBlock(filename: 'package.json', seed: 'json', code: _json),
  CodeBlock(
    language: 'bash',
    filename: 'terminal',
    wrap: true,
    seed: 'bash',
    code: _bash,
  ),
]);

Widget _paper() => _column(const [
  CodeBlock(
    code: _css,
    filename: 'card.css',
    tone: CodeBlockTone.paper,
    lineNumbers: true,
    startLine: 40,
    seed: 'paper',
  ),
  CodeBlock(
    code: _json,
    filename: 'package.json',
    tone: CodeBlockTone.paper,
    copyable: false,
    seed: 'focus',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CodeBlockHeader(children: [CodeBlockTitle()]),
        CodeBlockContent(forcedStates: {InkState.focused}),
      ],
    ),
  ),
]);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
      await loadIbmPlexMono();
    });
  });

  for (final (name, build) in [
    ('code-block-default', _default),
    ('code-block-diff', _diff),
    ('code-block-languages', _languages),
    ('code-block-paper', _paper),
  ]) {
    testWidgets('$name in the light theme', (tester) async {
      tester.view.physicalSize = const Size(1400, 1600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        componentHost(paperPanel(Center(child: build()))),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('../goldens/$name.png'),
      );
    });
  }
}
