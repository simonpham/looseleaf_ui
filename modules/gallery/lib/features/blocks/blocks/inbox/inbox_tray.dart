import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/inbox/inbox.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The letter tray: folder tabs, a search box, All or Unread, and the
/// letters of the folder (or what the folder says when it is empty).
///
/// Mirrors the tray `Paper` of upstream `src/blocks/inbox/page.tsx` and
/// `MailList` in `src/blocks/inbox/components/inbox-list.tsx`.
class InboxTray extends StatelessWidget {
  const InboxTray({
    super.key,
    required this.folder,
    required this.onFolder,
    required this.unreadCount,
    required this.query,
    required this.unreadOnly,
    required this.onUnreadOnly,
    required this.visible,
    required this.openId,
    required this.onOpen,
    required this.bounded,
  });

  final InboxFolder folder;
  final ValueChanged<InboxFolder> onFolder;
  final int unreadCount;
  final TextEditingController query;
  final bool unreadOnly;
  final ValueChanged<bool> onUnreadOnly;
  final List<InboxMail> visible;
  final String? openId;
  final ValueChanged<String> onOpen;

  /// Whether the tray has a fixed height, so the list scrolls inside it.
  final bool bounded;

  /// The tray width from which the folder tabs have room for their icons.
  static const double _iconsFrom = 420;

  /// Shares the row out by how much each tab has to say, so a narrow
  /// tray squeezes the long labels first.
  int _tabFlex(InboxFolder each) =>
      each.label.length +
      switch (each == InboxFolder.inbox && unreadCount > 0) {
        true => 3,
        false => 0,
      } +
      5;

  Widget _letters() {
    if (visible.isEmpty) {
      final filtered = query.text.trim().isNotEmpty || unreadOnly;
      final empty = inboxEmptyState(folder);
      return Empty(
        children: [
          EmptyHeader(
            children: [
              EmptyMedia(
                pose: switch (filtered) {
                  true => 'search',
                  false => empty.pose,
                },
                size: 80,
              ),
              EmptyTitle(
                child: Text(switch (filtered) {
                  true => 'No letters like that',
                  false => empty.title,
                }),
              ),
              EmptyDescription(
                child: Text(switch (filtered) {
                  true => 'Try another word, or show everything.',
                  false => empty.text,
                }),
              ),
            ],
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(Spacing.d12),
      child: ItemGroup(
        ruled: true,
        semanticLabel: '${folder.label}, newest first',
        children: [
          for (final mail in visible)
            InboxMailRow(
              key: ValueKey(mail.id),
              mail: mail,
              selected: mail.id == openId,
              onOpen: () => onOpen(mail.id),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final letters = TabsContent(value: folder.name, child: _letters());
    return Paper(
      stock: StockName.slip,
      tilt: false,
      seed: 'inbox-tray',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final withIcons = constraints.maxWidth >= _iconsFrom;
          return Tabs(
            value: folder.name,
            onValueChange: (value) =>
                onFolder(InboxFolder.values.byName(value)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.d12,
                  Spacing.d12,
                  Spacing.d12,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d12,
                  children: [
                    Semantics(
                      container: true,
                      label: 'Folders',
                      child: TabsList(
                        children: [
                          for (final each in InboxFolder.values)
                            Expanded(
                              flex: _tabFlex(each),
                              child: TabsTrigger(
                                value: each.name,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: Spacing.d6,
                                  children: [
                                    if (withIcons) InkIcon(each.icon),
                                    Flexible(
                                      child: Text(
                                        each.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (each == InboxFolder.inbox &&
                                        unreadCount > 0)
                                      Badge(
                                        variant: BadgeVariant.secondary,
                                        size: BadgeSize.sm,
                                        count: unreadCount,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      spacing: Spacing.d8,
                      children: [
                        Expanded(
                          child: Input(
                            controller: query,
                            placeholder: 'Search letters',
                            semanticLabel: 'Search letters',
                          ),
                        ),
                        ToggleGroup<bool>(
                          type: ToggleGroupType.single,
                          variant: ToggleVariant.outline,
                          size: ToggleSize.sm,
                          semanticLabel: 'Show',
                          value: {unreadOnly},
                          onChanged: (picked) {
                            if (picked.singleOrNull case final only?) {
                              onUnreadOnly(only);
                            }
                          },
                          children: const [
                            ToggleGroupItem(value: false, child: Text('All')),
                            ToggleGroupItem(
                              value: true,
                              child: Text('Unread'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              switch (bounded) {
                true => Expanded(
                  child: switch (visible.isEmpty) {
                    true => Center(child: letters),
                    false => SingleChildScrollView(child: letters),
                  },
                ),
                false => letters,
              },
            ],
          );
        },
      ),
    );
  }
}
