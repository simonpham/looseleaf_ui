import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemDropdownExample extends StatelessWidget {
  const ItemDropdownExample({super.key});

  static const _maxWidth = 448.0;
  static const _menuWidth = 288.0;
  static const _people = [
    (username: 'shadcn', email: 'shadcn@looseleaf.example'),
    (username: 'maxleiter', email: 'maxleiter@looseleaf.example'),
    (username: 'evilrabbit', email: 'evilrabbit@looseleaf.example'),
  ];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: _maxWidth,
      minHeight: Spacing.d256,
    ),
    child: Column(
      children: [
        DropdownMenu(
          content: DropdownMenuContent(
            minWidth: _menuWidth,
            align: OverlayAlign.end,
            children: [
              for (final person in _people)
                DropdownMenuItem(
                  onSelect: () {},
                  textValue: person.username,
                  child: InkItem(
                    size: ItemSize.sm,
                    children: [
                      ItemMedia(
                        child: Avatar(
                          children: [
                            AvatarFallback(child: Text(person.username[0])),
                          ],
                        ),
                      ),
                      ItemContent(
                        children: [
                          ItemTitle(Text(person.username)),
                          ItemDescription(Text(person.email)),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
          child: DropdownMenuTrigger.builder(
            builder: (context, menu) => Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              trailing: const InkIcon('chevron-down'),
              onPressed: menu.toggle,
              child: const Text('Select'),
            ),
          ),
        ),
      ],
    ),
  );
}
