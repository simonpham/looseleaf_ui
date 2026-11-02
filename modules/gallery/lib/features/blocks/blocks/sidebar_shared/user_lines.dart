import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';

/// The [user]'s name over their email, as [BrandText] draws a title.
///
/// Mirrors `Who` in upstream `src/blocks/sidebar-shared/sidebar-user-menu.tsx`.
class UserLines extends StatelessWidget {
  const UserLines({super.key, required this.user});

  final Person user;

  @override
  Widget build(BuildContext context) =>
      BrandText(title: user.name, subtitle: user.email);
}
