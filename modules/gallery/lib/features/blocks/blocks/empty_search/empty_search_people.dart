import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A contact: a name and what they do, where.
typedef EmptySearchPerson = ({String name, String role});

/// The address book.
const emptySearchPeople = <EmptySearchPerson>[
  (name: 'Ada Lovelace', role: 'Editor, London'),
  (name: 'Jo Okafor', role: 'Illustrator, Lagos'),
  (name: 'Mika Kobayashi', role: 'Bookbinder, Osaka'),
  (name: 'Sam Reyes', role: 'Printer, Lisbon'),
  (name: 'Priya Nair', role: 'Operations, Pune'),
  (name: 'Tomas Berg', role: 'Finance, Malmö'),
];

/// The people whose name or role contains [query], ignoring case; everyone
/// when it is blank.
List<EmptySearchPerson> findEmptySearchPeople(
  String query, [
  List<EmptySearchPerson> people = emptySearchPeople,
]) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return people;
  return [
    for (final person in people)
      if (person.name.toLowerCase().contains(needle) ||
          person.role.toLowerCase().contains(needle))
        person,
  ];
}

/// The matching contacts: an avatar, a name and a role per line.
///
/// Mirrors upstream `src/blocks/empty-search/components/empty-search-people.tsx`.
class EmptySearchList extends StatelessWidget {
  const EmptySearchList({super.key, required this.people});

  final List<EmptySearchPerson> people;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      label: 'Contacts',
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d4,
        children: [
          for (final person in people)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.d6),
              child: Row(
                spacing: Spacing.d12,
                children: [
                  Avatar(children: [AvatarFallback(name: person.name)]),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.face(
                            KevinSansFace.hand,
                            cssSize: 17,
                            cssLineHeight: 24 / 17,
                            fontWeight: FontWeight.w700,
                            color: theme.colors.ink,
                          ),
                        ),
                        Text(
                          person.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.face(
                            KevinSansFace.hand,
                            cssSize: 14,
                            cssLineHeight: 20 / 14,
                            color: theme.colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
