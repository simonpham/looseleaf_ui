import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MenubarDemoExample extends StatelessWidget {
  const MenubarDemoExample({super.key});

  @override
  Widget build(BuildContext context) => Menubar(
    children: [
      MenubarMenu(
        trigger: const MenubarTrigger(child: Text('File')),
        content: MenubarContent(
          children: [
            MenubarItem(
              onSelect: () {},
              trailing: const MenubarShortcut('⌘T'),
              child: const Text('New Tab'),
            ),
            MenubarItem(
              onSelect: () {},
              trailing: const MenubarShortcut('⌘N'),
              child: const Text('New Window'),
            ),
            const MenubarItem(
              disabled: true,
              child: Text('New Incognito Window'),
            ),
            const MenubarSeparator(),
            MenubarSub(
              trigger: const MenubarSubTrigger(child: Text('Share')),
              content: MenubarSubContent(
                children: [
                  MenubarItem(onSelect: () {}, child: const Text('Email link')),
                  MenubarItem(onSelect: () {}, child: const Text('Messages')),
                  MenubarItem(onSelect: () {}, child: const Text('Notes')),
                ],
              ),
            ),
            const MenubarSeparator(),
            MenubarItem(
              onSelect: () {},
              trailing: const MenubarShortcut('⌘P'),
              child: const Text('Print...'),
            ),
          ],
        ),
      ),
      MenubarMenu(
        trigger: const MenubarTrigger(child: Text('Edit')),
        content: MenubarContent(
          children: [
            MenubarItem(
              onSelect: () {},
              trailing: const MenubarShortcut('⌘Z'),
              child: const Text('Undo'),
            ),
            MenubarItem(
              onSelect: () {},
              trailing: const MenubarShortcut('⇧⌘Z'),
              child: const Text('Redo'),
            ),
            const MenubarSeparator(),
            MenubarSub(
              trigger: const MenubarSubTrigger(child: Text('Find')),
              content: MenubarSubContent(
                children: [
                  MenubarItem(
                    onSelect: () {},
                    child: const Text('Search the web'),
                  ),
                  const MenubarSeparator(),
                  MenubarItem(onSelect: () {}, child: const Text('Find...')),
                  MenubarItem(onSelect: () {}, child: const Text('Find Next')),
                  MenubarItem(
                    onSelect: () {},
                    child: const Text('Find Previous'),
                  ),
                ],
              ),
            ),
            const MenubarSeparator(),
            MenubarItem(onSelect: () {}, child: const Text('Cut')),
            MenubarItem(onSelect: () {}, child: const Text('Copy')),
            MenubarItem(onSelect: () {}, child: const Text('Paste')),
          ],
        ),
      ),
      MenubarMenu(
        trigger: const MenubarTrigger(child: Text('View')),
        content: MenubarContent(
          children: [
            const MenubarCheckboxItem(
              value: false,
              child: Text('Always Show Bookmarks Bar'),
            ),
            const MenubarCheckboxItem(
              value: true,
              child: Text('Always Show Full URLs'),
            ),
            const MenubarSeparator(),
            MenubarItem(
              inset: true,
              onSelect: () {},
              trailing: const MenubarShortcut('⌘R'),
              child: const Text('Reload'),
            ),
            const MenubarItem(
              disabled: true,
              inset: true,
              trailing: MenubarShortcut('⇧⌘R'),
              child: Text('Force Reload'),
            ),
            const MenubarSeparator(),
            MenubarItem(
              inset: true,
              onSelect: () {},
              child: const Text('Toggle Fullscreen'),
            ),
            const MenubarSeparator(),
            MenubarItem(
              inset: true,
              onSelect: () {},
              child: const Text('Hide Sidebar'),
            ),
          ],
        ),
      ),
      MenubarMenu(
        trigger: const MenubarTrigger(child: Text('Profiles')),
        content: MenubarContent(
          children: [
            const MenubarRadioGroup(
              value: 'benoit',
              children: [
                MenubarRadioItem(value: 'andy', child: Text('Andy')),
                MenubarRadioItem(value: 'benoit', child: Text('Benoit')),
                MenubarRadioItem(value: 'Luis', child: Text('Luis')),
              ],
            ),
            const MenubarSeparator(),
            MenubarItem(
              inset: true,
              onSelect: () {},
              child: const Text('Edit...'),
            ),
            const MenubarSeparator(),
            MenubarItem(
              inset: true,
              onSelect: () {},
              child: const Text('Add Profile...'),
            ),
          ],
        ),
      ),
    ],
  );
}
