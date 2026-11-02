import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _fix = '''-export const label = "all";
+export const label = picked.size ? "filtered" : "all";''';

class CodeBlockInAChatExample extends StatelessWidget {
  const CodeBlockInAChatExample({super.key});

  static const _maxWidth = 512.0;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.d12,
          vertical: Spacing.d16,
        ),
        child: Message(
          children: [
            MessageContent(
              children: [
                MessageHeader(child: Text('Stubby')),
                Bubble(
                  variant: BubbleVariant.ghost,
                  children: [
                    BubbleContent(child: Text('Here is the one-line fix:')),
                  ],
                ),
                CodeBlock(
                  diff: true,
                  language: 'ts',
                  filename: 'filter.ts',
                  seed: 'chat',
                  code: _fix,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
