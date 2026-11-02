import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MenubarAppMenuExample extends StatefulWidget {
  const MenubarAppMenuExample({super.key});

  @override
  State<MenubarAppMenuExample> createState() => _MenubarAppMenuExampleState();
}

class _MenubarAppMenuExampleState extends State<MenubarAppMenuExample> {
  bool _bookmarks = false;
  bool _urls = true;
  String _profile = 'benoit';

  @override
  Widget build(BuildContext context) => Menubar(
    seed: 'app',
    children: [
      MenubarMenu(
        trigger: const MenubarTrigger(child: Text('File')),
        content: MenubarContent(
          children: [
            MenubarItem(
              onSelect: () {},
              trailing: const MenubarShortcut('⌘T'),
              child: const Text('New tab'),
            ),
            MenubarItem(
              onSelect: () {},
              trailing: const MenubarShortcut('⌘N'),
              child: const Text('New window'),
            ),
            const MenubarItem(
              disabled: true,
              child: Text('New incognito window'),
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
              child: const Text('Print…'),
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
                  MenubarItem(onSelect: () {}, child: const Text('Find…')),
                  MenubarItem(onSelect: () {}, child: const Text('Find next')),
                  MenubarItem(
                    onSelect: () {},
                    child: const Text('Find previous'),
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
            MenubarCheckboxItem(
              value: _bookmarks,
              onChanged: (value) => setState(() => _bookmarks = value),
              child: const Text('Always show bookmarks bar'),
            ),
            MenubarCheckboxItem(
              value: _urls,
              onChanged: (value) => setState(() => _urls = value),
              child: const Text('Always show full URLs'),
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
              child: Text('Force reload'),
            ),
            const MenubarSeparator(),
            MenubarItem(
              inset: true,
              onSelect: () {},
              child: const Text('Toggle full screen'),
            ),
          ],
        ),
      ),
      MenubarMenu(
        trigger: const MenubarTrigger(child: Text('Profiles')),
        content: MenubarContent(
          children: [
            MenubarRadioGroup(
              value: _profile,
              onChanged: (value) => setState(() => _profile = value),
              children: const [
                MenubarRadioItem(value: 'andy', child: Text('Andy')),
                MenubarRadioItem(value: 'benoit', child: Text('Benoit')),
                MenubarRadioItem(value: 'luis', child: Text('Luis')),
              ],
            ),
            const MenubarSeparator(),
            MenubarItem(
              inset: true,
              onSelect: () {},
              child: const Text('Edit…'),
            ),
            const MenubarSeparator(),
            MenubarItem(
              inset: true,
              onSelect: () {},
              child: const Text('Add profile…'),
            ),
          ],
        ),
      ),
    ],
  );
}
