import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupAgentPopoverExample extends StatelessWidget {
  const ButtonGroupAgentPopoverExample({super.key});

  static const _width = 320.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.interface(cssSize: 14);
    final bold = small.copyWith(fontWeight: FontWeight.w700);
    return ButtonGroup(
      semanticLabel: 'Copilot',
      children: [
        Button(
          variant: ButtonVariant.outline,
          leading: const InkIcon('bot'),
          onPressed: () {},
          child: const Text('Copilot'),
        ),
        Popover(
          content: PopoverContent(
            align: OverlayAlign.end,
            width: _width,
            padding: EdgeInsets.zero,
            semanticLabel: 'Agent tasks',
            seed: 'copilot',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.d16,
                    vertical: Spacing.d12,
                  ),
                  child: Text('Agent tasks', style: bold),
                ),
                const Separator(),
                Padding(
                  padding: const EdgeInsets.all(Spacing.d16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d8,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: Spacing.d8),
                        child: Textarea(
                          placeholder:
                              'Describe your task in natural language.',
                          resizable: false,
                          semanticLabel: 'Task',
                        ),
                      ),
                      Text('Start a new task with Copilot', style: bold),
                      Text(
                        'Describe your task in natural language. Copilot will work in the background and open a pull request for your review.',
                        style: small.copyWith(color: theme.colors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          child: PopoverTrigger.builder(
            builder: (context, popover) => Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.icon,
              semanticLabel: 'Open the task popover',
              onPressed: popover.toggle,
              child: const InkIcon('chevron-down'),
            ),
          ),
        ),
      ],
    );
  }
}
