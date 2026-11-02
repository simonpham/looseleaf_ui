import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyAvatarGroupExample extends StatelessWidget {
  const EmptyAvatarGroupExample({super.key});

  @override
  Widget build(BuildContext context) => Empty(
    children: [
      const EmptyHeader(
        children: [
          EmptyMedia(
            child: AvatarGroup(
              size: AvatarSize.lg,
              children: [
                Avatar(children: [AvatarFallback(child: Text('CN'))]),
                Avatar(children: [AvatarFallback(child: Text('LR'))]),
                Avatar(children: [AvatarFallback(child: Text('ER'))]),
              ],
            ),
          ),
          EmptyTitle(child: Text('No Team Members')),
          EmptyDescription(
            child: Text('Invite your team to collaborate on this project.'),
          ),
        ],
      ),
      EmptyContent(
        children: [
          Button(
            size: ButtonSize.sm,
            leading: const InkIcon('plus'),
            onPressed: () {},
            child: const Text('Invite Members'),
          ),
        ],
      ),
    ],
  );
}
