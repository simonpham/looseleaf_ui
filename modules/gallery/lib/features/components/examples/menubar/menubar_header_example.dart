import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MenubarHeaderExample extends StatefulWidget {
  const MenubarHeaderExample({super.key});

  @override
  State<MenubarHeaderExample> createState() => _MenubarHeaderExampleState();
}

class _MenubarHeaderExampleState extends State<MenubarHeaderExample> {
  static const _maxWidth = 672.0;

  String _said = 'Nothing chosen yet.';

  VoidCallback _pick(String what) =>
      () => setState(() => _said = what);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Paper(
        seed: 'app-header',
        padding: const EdgeInsets.fromLTRB(
          Spacing.d20,
          Spacing.d12,
          Spacing.d20,
          Spacing.d16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d12,
          children: [
            Row(
              spacing: Spacing.d12,
              children: [
                Expanded(
                  child: Row(
                    spacing: Spacing.d12,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Spacing.d8,
                        children: [
                          const InkIcon('book-open', size: Spacing.d22),
                          Text(
                            'Looseleaf',
                            style: theme.typography.face(
                              KevinSansFace.script,
                              cssSize: 24,
                              cssLineHeight: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Menubar(
                          seed: 'header',
                          semanticLabel: 'Application',
                          children: [
                            MenubarMenu(
                              trigger: const MenubarTrigger(
                                child: Text('Notebook'),
                              ),
                              content: MenubarContent(
                                children: [
                                  MenubarItem(
                                    onSelect: _pick('New notebook'),
                                    leading: const InkIcon('file-plus'),
                                    trailing: const MenubarShortcut('⌘N'),
                                    child: const Text('New'),
                                  ),
                                  MenubarItem(
                                    onSelect: _pick('Opened'),
                                    leading: const InkIcon('folder-open'),
                                    trailing: const MenubarShortcut('⌘O'),
                                    child: const Text('Open…'),
                                  ),
                                  const MenubarSeparator(),
                                  MenubarItem(
                                    onSelect: _pick('Saved'),
                                    leading: const InkIcon('save'),
                                    trailing: const MenubarShortcut('⌘S'),
                                    child: const Text('Save'),
                                  ),
                                  MenubarItem(
                                    variant: InkMenuItemVariant.destructive,
                                    onSelect: _pick('Moved to trash'),
                                    leading: const InkIcon('trash'),
                                    child: const Text('Move to trash'),
                                  ),
                                ],
                              ),
                            ),
                            MenubarMenu(
                              trigger: const MenubarTrigger(
                                child: Text('Help'),
                              ),
                              content: MenubarContent(
                                children: [
                                  MenubarItem(
                                    onSelect: _pick('Guide'),
                                    leading: const InkIcon('life-buoy'),
                                    child: const Text('Guide'),
                                  ),
                                  MenubarItem(
                                    onSelect: _pick('Shortcuts'),
                                    leading: const InkIcon('command'),
                                    trailing: const MenubarShortcut('⌘/'),
                                    child: const Text('Shortcuts'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.icon,
                  semanticLabel: 'Account',
                  onPressed: () {},
                  child: const InkIcon('circle-user', size: Spacing.d20),
                ),
              ],
            ),
            Semantics(
              liveRegion: true,
              child: Text(
                _said,
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
