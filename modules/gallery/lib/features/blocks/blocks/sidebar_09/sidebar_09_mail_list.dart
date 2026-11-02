import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_09/sidebar_09.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The second sheet on the mail pad: the folder's name with an Unreads
/// switch, a search box, and the letters that match.
class Sidebar09MailList extends StatefulWidget {
  const Sidebar09MailList({
    super.key,
    required this.folder,
    required this.unread,
    required this.selectedId,
    required this.onSelectMail,
  });

  final MailFolder folder;
  final Set<String> unread;
  final String? selectedId;
  final ValueChanged<String> onSelectMail;

  @override
  State<Sidebar09MailList> createState() => _Sidebar09MailListState();
}

class _Sidebar09MailListState extends State<Sidebar09MailList> {
  bool _unreadOnly = false;
  String _query = '';

  bool _matches(Mail mail) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      mail.name,
      mail.subject,
      mail.teaser,
    ].any((text) => text.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final data = SidebarProvider.of(context);
    final visible = [
      for (final mail in mails)
        if (mail.folder == widget.folder &&
            (!_unreadOnly || widget.unread.contains(mail.id)) &&
            _matches(mail))
          mail,
    ];
    return Sidebar(
      collapsible: SidebarCollapsible.none,
      stock: StockName.card,
      seed: 'sidebar-09-list',
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.d16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d14,
            children: [
              Row(
                spacing: Spacing.d8,
                children: [
                  Expanded(
                    child: Text(
                      widget.folder.title,
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 24,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w600,
                        color: theme.colors.ink,
                      ),
                    ),
                  ),
                  Text(
                    'Unreads',
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 14,
                      color: theme.colors.ink,
                    ),
                  ),
                  Switch(
                    size: SwitchSize.sm,
                    semanticLabel: 'Unreads',
                    value: _unreadOnly,
                    onChanged: (value) => setState(() => _unreadOnly = value),
                  ),
                ],
              ),
              SidebarInput(
                placeholder: 'Type to search...',
                semanticLabel: 'Search mail',
                onChanged: (value) => setState(() => _query = value),
              ),
            ],
          ),
        ),
        const Separator(),
        SidebarContent(
          children: [
            if (visible.isEmpty)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.d16),
                  child: Text(
                    'No letters here. Try another folder, or clear the search.',
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
            for (final (index, mail) in visible.indexed) ...[
              if (index > 0) const Separator(),
              Sidebar09MailRow(
                mail: mail,
                unread: widget.unread.contains(mail.id),
                current: mail.id == widget.selectedId,
                onPressed: () {
                  widget.onSelectMail(mail.id);
                  if (data.isMobile) data.setOpenMobile(false);
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
