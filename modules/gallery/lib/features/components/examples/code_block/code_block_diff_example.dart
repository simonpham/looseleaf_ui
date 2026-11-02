import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _patch = '''-const shown = notes;
+const shown = picked.size
+  ? notes.filter((n) => picked.has(n.tag))
+  : notes;
 export const count = shown.length;
-export const label = "all";
+export const label = picked.size ? "filtered" : "all";''';

class CodeBlockDiffExample extends StatelessWidget {
  const CodeBlockDiffExample({super.key});

  static const _maxWidth = 576.0;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const CodeBlock(
        diff: true,
        code: _patch,
        language: 'ts',
        filename: 'src/notes/filter.ts',
        lineNumbers: true,
        seed: 'diff',
      ),
    ),
  );
}
