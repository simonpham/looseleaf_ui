import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _code = '''import { useState } from "react"

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

class CodeBlockDefaultExample extends StatelessWidget {
  const CodeBlockDefaultExample({super.key});

  static const _maxWidth = 576.0;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const CodeBlock(
        code: _code,
        filename: 'src/notes/tag-chips.tsx',
        lineNumbers: true,
        seed: 'default',
      ),
    ),
  );
}
