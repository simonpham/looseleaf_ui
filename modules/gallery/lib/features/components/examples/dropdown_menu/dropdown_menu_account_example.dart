import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DropdownMenuAccountExample extends StatelessWidget {
  const DropdownMenuAccountExample({super.key});

  static const _width = Spacing.d240;

  @override
  Widget build(BuildContext context) => DropdownMenu(
    content: DropdownMenuContent(
      minWidth: _width,
      align: OverlayAlign.start,
      seed: 'account',
      children: [
        const DropdownMenuLabel(child: Text('My account')),
        DropdownMenuGroup(
          children: [
            DropdownMenuItem(
              leading: const InkIcon('user'),
              trailing: const DropdownMenuShortcut('⇧⌘P'),
              onSelect: () {},
              child: const Text('Profile'),
            ),
            DropdownMenuItem(
              leading: const InkIcon('credit-card'),
              trailing: const DropdownMenuShortcut('⌘B'),
              onSelect: () {},
              child: const Text('Billing'),
            ),
            DropdownMenuItem(
              leading: const InkIcon('settings'),
              trailing: const DropdownMenuShortcut('⌘,'),
              onSelect: () {},
              child: const Text('Settings'),
            ),
            const DropdownMenuItem(
              leading: InkIcon('user-plus'),
              disabled: true,
              child: Text('Invite users'),
            ),
          ],
        ),
        const DropdownMenuSeparator(),
        DropdownMenuSub(
          trigger: const DropdownMenuSubTrigger(
            leading: InkIcon('users'),
            child: Text('Team'),
          ),
          content: DropdownMenuSubContent(
            children: [
              DropdownMenuItem(
                leading: const InkIcon('mail'),
                onSelect: () {},
                child: const Text('Email'),
              ),
              DropdownMenuItem(
                leading: const InkIcon('message-square'),
                onSelect: () {},
                child: const Text('Message'),
              ),
              const DropdownMenuSeparator(),
              DropdownMenuItem(
                leading: const InkIcon('plus'),
                onSelect: () {},
                child: const Text('More…'),
              ),
            ],
          ),
        ),
        const DropdownMenuSeparator(),
        DropdownMenuItem(
          variant: InkMenuItemVariant.destructive,
          leading: const InkIcon('log-out'),
          trailing: const DropdownMenuShortcut('⇧⌘Q'),
          onSelect: () {},
          child: const Text('Log out'),
        ),
      ],
    ),
    child: DropdownMenuTrigger.builder(
      builder: (context, menu) => Button(
        variant: ButtonVariant.outline,
        onPressed: menu.toggle,
        child: const Text('Open'),
      ),
    ),
  );
}
