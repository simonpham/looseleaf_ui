import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupDemoExample extends StatelessWidget {
  const InputGroupDemoExample({super.key});

  @override
  Widget build(BuildContext context) => TooltipProvider(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d24,
        children: [
          const InputGroup(
            children: [
              InputGroupInput(
                placeholder: 'Search...',
                semanticLabel: 'Search',
              ),
              InputGroupAddon(child: InkIcon('search')),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: Text('12 results'),
              ),
            ],
          ),
          const InputGroup(
            children: [
              InputGroupInput(
                placeholder: 'example.com',
                semanticLabel: 'Website',
              ),
              InputGroupAddon(child: InputGroupText(child: Text('https://'))),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: Tooltip(
                  content: TooltipContent(
                    child: Text('This is content in a tooltip.'),
                  ),
                  child: InputGroupButton(
                    size: InputGroupButtonSize.iconXs,
                    semanticLabel: 'Info',
                    child: InkIcon('info'),
                  ),
                ),
              ),
            ],
          ),
          InputGroup(
            children: [
              const InputGroupTextarea(
                placeholder: 'Ask, Search or Chat...',
                semanticLabel: 'Prompt',
              ),
              InputGroupAddon(
                align: InputGroupAlign.blockEnd,
                child: Row(
                  spacing: Spacing.d8,
                  children: [
                    InputGroupButton(
                      variant: ButtonVariant.outline,
                      size: InputGroupButtonSize.iconXs,
                      semanticLabel: 'Add',
                      onPressed: () {},
                      child: const InkIcon('plus'),
                    ),
                    DropdownMenu(
                      content: const DropdownMenuContent(
                        side: OverlaySide.top,
                        align: OverlayAlign.start,
                        children: [
                          DropdownMenuItem(child: Text('Auto')),
                          DropdownMenuItem(child: Text('Agent')),
                          DropdownMenuItem(child: Text('Manual')),
                        ],
                      ),
                      child: DropdownMenuTrigger.builder(
                        builder: (context, menu) => InputGroupButton(
                          onPressed: menu.toggle,
                          child: const Text('Auto'),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const InputGroupText(child: Text('52% used')),
                    const SizedBox(
                      height: Spacing.d16,
                      child: Separator(
                        orientation: SeparatorOrientation.vertical,
                      ),
                    ),
                    const InputGroupButton(
                      variant: ButtonVariant.primary,
                      size: InputGroupButtonSize.iconXs,
                      disabled: true,
                      semanticLabel: 'Send',
                      child: InkIcon('arrow-up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const InputGroup(
            children: [
              InputGroupInput(placeholder: '@shadcn', semanticLabel: 'Handle'),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: InkIcon('badge-check', semanticLabel: 'Verified'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
