import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyAvatarExample extends StatelessWidget {
  const EmptyAvatarExample({super.key});

  @override
  Widget build(BuildContext context) => Empty(
    children: [
      const EmptyHeader(
        children: [
          EmptyMedia(
            child: Avatar(
              dimension: Spacing.d48,
              children: [AvatarFallback(child: Text('LR'))],
            ),
          ),
          EmptyTitle(child: Text('User Offline')),
          EmptyDescription(
            child: Text(
              'This user is currently offline. You can leave a message to notify them or try again later.',
            ),
          ),
        ],
      ),
      EmptyContent(
        children: [
          Button(
            size: ButtonSize.sm,
            onPressed: () {},
            child: const Text('Leave Message'),
          ),
        ],
      ),
    ],
  );
}
