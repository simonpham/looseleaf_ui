import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_11/sidebar_11.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A code editor's file pad: pick a file and the trail and title above
/// follow it.
///
/// Mirrors upstream `src/blocks/sidebar-11/page.tsx`.
class Sidebar11Block extends StatefulWidget {
  const Sidebar11Block({super.key});

  @override
  State<Sidebar11Block> createState() => _Sidebar11BlockState();
}

class _Sidebar11BlockState extends State<Sidebar11Block> {
  String _active = 'components/ui/button.tsx';

  static const double _height = 640;

  @override
  Widget build(BuildContext context) {
    final parts = _active.split('/');
    final file = parts.last;
    return SizedBox(
      height: _height,
      child: SidebarProvider(
        children: [
          Sidebar11AppSidebar(
            active: _active,
            onPick: (path) => setState(() => _active = path),
          ),
          SidebarPageSheet(
            children: [
              SidebarPageHeader(crumbs: parts, bordered: true),
              SidebarPageBody(
                title: file,
                kicker: switch (parts.length > 1) {
                  true => parts.take(parts.length - 1).join(' / '),
                  false => 'project root',
                },
                children: [
                  SidebarPageNote(
                    title: 'No editor here yet',
                    pose: 'think',
                    description:
                        'This is where $file would open. Pick another file on the pad and the trail above follows you.',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
