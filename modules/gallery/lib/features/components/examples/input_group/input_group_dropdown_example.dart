import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupDropdownExample extends StatelessWidget {
  const InputGroupDropdownExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          InputGroup(
            children: [
              const InputGroupInput(
                placeholder: 'Enter file name',
                semanticLabel: 'File name',
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: DropdownMenu(
                  content: const DropdownMenuContent(
                    align: OverlayAlign.end,
                    children: [
                      DropdownMenuItem(child: Text('Settings')),
                      DropdownMenuItem(child: Text('Copy path')),
                      DropdownMenuItem(child: Text('Open location')),
                    ],
                  ),
                  child: DropdownMenuTrigger.builder(
                    builder: (context, menu) => InputGroupButton(
                      size: InputGroupButtonSize.iconXs,
                      semanticLabel: 'More',
                      onPressed: menu.toggle,
                      child: const InkIcon('ellipsis'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          InputGroup(
            children: [
              const InputGroupInput(
                placeholder: 'Enter search query',
                semanticLabel: 'Search query',
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: DropdownMenu(
                  content: const DropdownMenuContent(
                    align: OverlayAlign.end,
                    children: [
                      DropdownMenuItem(child: Text('Documentation')),
                      DropdownMenuItem(child: Text('Blog Posts')),
                      DropdownMenuItem(child: Text('Changelog')),
                    ],
                  ),
                  child: DropdownMenuTrigger.builder(
                    builder: (context, menu) => InputGroupButton(
                      onPressed: menu.toggle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Spacing.d4,
                        children: [
                          Text(
                            'Search In...',
                            style: theme.typography.interface(cssSize: 12),
                          ),
                          const InkIcon('chevron-down', size: Spacing.d12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
