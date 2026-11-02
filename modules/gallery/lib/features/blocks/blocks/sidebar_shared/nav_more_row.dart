import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The "More" row closing a list, in softer ink.
class NavMoreRow extends StatelessWidget {
  const NavMoreRow({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SidebarMenuItem(
    child: SidebarMenuButton(
      leading: const InkIcon('ellipsis'),
      onPressed: onPressed ?? () {},
      child: Text(
        'More',
        style: TextStyle(color: LooseleafTheme.of(context).colors.inkSoft),
      ),
    ),
  );
}
