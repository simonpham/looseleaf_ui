import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupTextareaExample extends StatelessWidget {
  const InputGroupTextareaExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: InputGroup(
        children: [
          const InputGroupTextarea(
            placeholder: "console.log('Hello, world!');",
            semanticLabel: 'Code',
            minLines: 8,
          ),
          InputGroupAddon(
            align: InputGroupAlign.blockEnd,
            border: InputGroupEdge.top,
            child: Row(
              children: [
                const InputGroupText(child: Text('Line 1, Column 1')),
                const Spacer(),
                InputGroupButton(
                  size: InputGroupButtonSize.sm,
                  variant: ButtonVariant.primary,
                  onPressed: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.d6,
                    children: [Text('Run'), InkIcon('play')],
                  ),
                ),
              ],
            ),
          ),
          InputGroupAddon(
            align: InputGroupAlign.blockStart,
            border: InputGroupEdge.bottom,
            child: Row(
              spacing: Spacing.d4,
              children: [
                InputGroupText(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.d8,
                    children: [
                      const InkIcon('file-code'),
                      Text(
                        'script.js',
                        style: theme.typography.mono(
                          cssSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                InputGroupButton(
                  size: InputGroupButtonSize.iconXs,
                  semanticLabel: 'Refresh',
                  onPressed: () {},
                  child: const InkIcon('rotate-cw'),
                ),
                InputGroupButton(
                  size: InputGroupButtonSize.iconXs,
                  semanticLabel: 'Copy',
                  onPressed: () {},
                  child: const InkIcon('copy'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
