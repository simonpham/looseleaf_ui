import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupFollowMenuExample extends StatefulWidget {
  const ButtonGroupFollowMenuExample({super.key});

  @override
  State<ButtonGroupFollowMenuExample> createState() =>
      _ButtonGroupFollowMenuExampleState();
}

class _ButtonGroupFollowMenuExampleState
    extends State<ButtonGroupFollowMenuExample> {
  static const _menuWidth = Spacing.d224;
  static const _actions = [
    ('volume-off', 'Mute conversation'),
    ('check', 'Mark as read'),
    ('flag', 'Report conversation'),
    ('ban', 'Block user'),
    ('share', 'Share conversation'),
    ('copy', 'Copy conversation'),
  ];

  var _following = false;

  @override
  Widget build(BuildContext context) => ButtonGroup(
    semanticLabel: 'Conversation',
    children: [
      Semantics(
        toggled: _following,
        child: Button(
          variant: ButtonVariant.outline,
          onPressed: () => setState(() => _following = !_following),
          child: Text(switch (_following) {
            true => 'Following',
            false => 'Follow',
          }),
        ),
      ),
      DropdownMenu(
        content: DropdownMenuContent(
          align: OverlayAlign.end,
          width: _menuWidth,
          seed: 'follow-menu',
          children: [
            DropdownMenuGroup(
              children: [
                for (final (icon, label) in _actions)
                  DropdownMenuItem(
                    leading: InkIcon(icon),
                    onSelect: () {},
                    child: Text(label),
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
                  child: const Text('Delete conversation'),
                ),
              ],
            ),
          ],
        ),
        child: DropdownMenuTrigger.builder(
          builder: (context, menu) => Button(
            variant: ButtonVariant.outline,
            size: ButtonSize.icon,
            semanticLabel: 'More conversation actions',
            onPressed: menu.toggle,
            child: const InkIcon('chevron-down'),
          ),
        ),
      ),
    ],
  );
}
