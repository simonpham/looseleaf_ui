import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupMailToolbarExample extends StatefulWidget {
  const ButtonGroupMailToolbarExample({super.key});

  @override
  State<ButtonGroupMailToolbarExample> createState() =>
      _ButtonGroupMailToolbarExampleState();
}

class _ButtonGroupMailToolbarExampleState
    extends State<ButtonGroupMailToolbarExample> {
  static const _menuWidth = 208.0;
  static const _smallBreakpoint = 640.0;

  var _label = 'personal';

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ButtonGroup(
      semanticLabel: 'Message actions',
      children: [
        if (MediaQuery.sizeOf(context).width >= _smallBreakpoint)
          ButtonGroup(
            children: [
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.icon,
                semanticLabel: 'Go back',
                onPressed: () {},
                child: const InkIcon('arrow-left'),
              ),
            ],
          ),
        ButtonGroup(
          children: [
            Button(
              variant: ButtonVariant.outline,
              onPressed: () {},
              child: const Text('Archive'),
            ),
            Button(
              variant: ButtonVariant.outline,
              onPressed: () {},
              child: const Text('Report'),
            ),
          ],
        ),
        ButtonGroup(
          children: [
            Button(
              variant: ButtonVariant.outline,
              onPressed: () {},
              child: const Text('Snooze'),
            ),
            DropdownMenu(
              content: DropdownMenuContent(
                align: OverlayAlign.end,
                width: _menuWidth,
                seed: 'mail-more',
                children: [
                  DropdownMenuGroup(
                    children: [
                      DropdownMenuItem(
                        leading: const InkIcon('mail-check'),
                        onSelect: () {},
                        child: const Text('Mark as read'),
                      ),
                      DropdownMenuItem(
                        leading: const InkIcon('archive'),
                        onSelect: () {},
                        child: const Text('Archive'),
                      ),
                    ],
                  ),
                  const DropdownMenuSeparator(),
                  DropdownMenuGroup(
                    children: [
                      DropdownMenuItem(
                        leading: const InkIcon('clock'),
                        onSelect: () {},
                        child: const Text('Snooze'),
                      ),
                      DropdownMenuItem(
                        leading: const InkIcon('calendar-plus'),
                        onSelect: () {},
                        child: const Text('Add to calendar'),
                      ),
                      DropdownMenuItem(
                        leading: const InkIcon('list-filter'),
                        onSelect: () {},
                        child: const Text('Add to list'),
                      ),
                      DropdownMenuSub(
                        trigger: const DropdownMenuSubTrigger(
                          leading: InkIcon('tag'),
                          child: Text('Label as...'),
                        ),
                        content: DropdownMenuSubContent(
                          children: [
                            DropdownMenuRadioGroup(
                              value: _label,
                              onChanged: (label) =>
                                  setState(() => _label = label),
                              children: const [
                                DropdownMenuRadioItem(
                                  value: 'personal',
                                  child: Text('Personal'),
                                ),
                                DropdownMenuRadioItem(
                                  value: 'work',
                                  child: Text('Work'),
                                ),
                                DropdownMenuRadioItem(
                                  value: 'other',
                                  child: Text('Other'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const DropdownMenuSeparator(),
                  DropdownMenuGroup(
                    children: [
                      DropdownMenuItem(
                        variant: InkMenuItemVariant.destructive,
                        leading: const InkIcon('trash'),
                        onSelect: () {},
                        child: const Text('Trash'),
                      ),
                    ],
                  ),
                ],
              ),
              child: DropdownMenuTrigger.builder(
                builder: (context, menu) => Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.icon,
                  semanticLabel: 'More options',
                  onPressed: menu.toggle,
                  child: const InkIcon('ellipsis'),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
