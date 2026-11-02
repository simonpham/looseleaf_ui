import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_09/sidebar_09.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A mail app: folders on a strip, the folder's letters beside them, and
/// the letter you pick open on the page, marked read until you say
/// otherwise.
///
/// Mirrors upstream `src/blocks/sidebar-09/page.tsx`.
class Sidebar09Block extends StatefulWidget {
  const Sidebar09Block({super.key});

  @override
  State<Sidebar09Block> createState() => _Sidebar09BlockState();
}

class _Sidebar09BlockState extends State<Sidebar09Block> {
  MailFolder _folder = MailFolder.inbox;
  String? _selectedId;
  final Set<String> _unread = {
    for (final mail in mails)
      if (mail.unread) mail.id,
  };

  static const double _height = 640;

  /// `--sidebar-width: 350px`.
  static const double _sidebarWidth = 350;

  void _setRead(String id, {required bool read}) => setState(() {
    if (read) {
      _unread.remove(id);
      return;
    }
    _unread.add(id);
  });

  @override
  Widget build(BuildContext context) {
    final selected = mails.where((mail) => mail.id == _selectedId).firstOrNull;
    return SizedBox(
      height: _height,
      child: SidebarProvider(
        width: _sidebarWidth,
        children: [
          Sidebar09AppSidebar(
            folder: _folder,
            onFolderChange: (next) => setState(() {
              _folder = next;
              _selectedId = null;
            }),
            unread: _unread,
            selectedId: _selectedId,
            onSelectMail: (id) {
              setState(() => _selectedId = id);
              _setRead(id, read: true);
            },
          ),
          SidebarPageSheet(
            children: [
              SidebarPageHeader(
                crumbs: ['All inboxes', _folder.title],
                bordered: true,
              ),
              switch (selected) {
                final mail? => SidebarPageBody(
                  title: mail.subject,
                  kicker: 'From ${mail.name}',
                  children: [
                    Sidebar09Letter(
                      mail: mail,
                      onMarkUnread: () => _setRead(mail.id, read: false),
                    ),
                  ],
                ),
                null => SidebarPageBody(
                  title: _folder.title,
                  kicker: 'All inboxes',
                  children: const [
                    SidebarPageNote(
                      title: 'No letter open',
                      pose: 'idle',
                      description: 'Pick a message from the list on the pad and it opens here, ready to read.',
                    ),
                  ],
                ),
              },
            ],
          ),
        ],
      ),
    );
  }
}
