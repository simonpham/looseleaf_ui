import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CommandDefaultExample extends StatelessWidget {
  const CommandDefaultExample({super.key});

  static const _width = 352.0;

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: _width,
    child: Command(
      semanticLabel: 'Commands',
      children: [
        CommandInput(
          placeholder: 'Type a command or search...',
          autofocus: false,
        ),
        CommandList(
          children: [
            CommandEmpty(child: Text('No results found.')),
            CommandGroup(
              heading: Text('Suggestions'),
              children: [
                CommandItem(
                  leading: InkIcon('calendar'),
                  child: Text('Calendar'),
                ),
                CommandItem(
                  leading: InkIcon('face-slightly-smiling'),
                  child: Text('Search Emoji'),
                ),
                CommandItem(
                  disabled: true,
                  leading: InkIcon('calculator'),
                  child: Text('Calculator'),
                ),
              ],
            ),
            CommandSeparator(),
            CommandGroup(
              heading: Text('Settings'),
              children: [
                CommandItem(
                  leading: InkIcon('user'),
                  trailing: CommandShortcut('Ctrl P'),
                  child: Text('Profile'),
                ),
                CommandItem(
                  leading: InkIcon('credit-card'),
                  trailing: CommandShortcut('Ctrl B'),
                  child: Text('Billing'),
                ),
                CommandItem(
                  leading: InkIcon('settings'),
                  trailing: CommandShortcut('Ctrl S'),
                  child: Text('Settings'),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
