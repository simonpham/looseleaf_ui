import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The [user]'s initials on a sky-blue avatar, 32 px.
///
/// Mirrors `Face` in upstream `src/blocks/sidebar-shared/sidebar-user-menu.tsx`.
class UserFace extends StatelessWidget {
  const UserFace({super.key, required this.user});

  final Person user;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Avatar(
      children: [
        AvatarFallback(tone: AvatarTone.sky, child: Text(user.initials)),
      ],
    ),
  );
}
