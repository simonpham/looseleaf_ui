import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _css = '''@media (min-width: 40rem) {
  .card > h1 {
    color: var(--ll-ink); /* felt */
    margin: -2px 1.5rem !important;
  }
}''';

const _json = '''{
  "name": "looseleaf",
  "private": true,
  "keywords": ["paper", null]
}''';

const _bash = r'''$ npx shadcn add https://kevintngo.github.io/looseleaf/r/bubble.json https://kevintngo.github.io/looseleaf/r/message.json --overwrite
# then draw something
export FOO=$BAR && echo "${FOO}" | grep -i tags''';

class CodeBlockLanguagesExample extends StatelessWidget {
  const CodeBlockLanguagesExample({super.key});

  static const _maxWidth = 576.0;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const Padding(
        padding: EdgeInsets.only(top: Spacing.d8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d40,
          children: [
            CodeBlock(filename: 'card.css', seed: 'css', code: _css),
            CodeBlock(filename: 'package.json', seed: 'json', code: _json),
            CodeBlock(
              language: 'bash',
              filename: 'terminal',
              wrap: true,
              seed: 'bash',
              code: _bash,
            ),
          ],
        ),
      ),
    ),
  );
}
