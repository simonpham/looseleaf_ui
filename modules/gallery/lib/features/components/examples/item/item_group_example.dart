import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemGroupExample extends StatelessWidget {
  const ItemGroupExample({super.key});

  static const _maxWidth = 448.0;
  static const _people = [
    (username: 'shadcn', email: 'shadcn@looseleaf.example'),
    (username: 'maxleiter', email: 'maxleiter@looseleaf.example'),
    (username: 'evilrabbit', email: 'evilrabbit@looseleaf.example'),
  ];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: ItemGroup(
      children: [
        for (final (index, person) in _people.indexed) ...[
          InkItem(
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
              ItemActions(
                children: [
                  Button(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.icon,
                    semanticLabel: 'Add ${person.username}',
                    onPressed: () {},
                    child: const InkIcon('plus'),
                  ),
                ],
              ),
            ],
          ),
          if (index != _people.length - 1) const ItemSeparator(),
        ],
      ],
    ),
  );
}
