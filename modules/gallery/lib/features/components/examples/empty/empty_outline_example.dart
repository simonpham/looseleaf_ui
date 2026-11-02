import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyOutlineExample extends StatelessWidget {
  const EmptyOutlineExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 576),
    child: Empty(
      framed: true,
      children: [
        const EmptyHeader(
          children: [
            EmptyMedia(
              variant: EmptyMediaVariant.icon,
              child: InkIcon('cloud'),
            ),
            EmptyTitle(child: Text('Cloud Storage Empty')),
            EmptyDescription(
              child: Text(
                'Upload files to your cloud storage to access them anywhere.',
              ),
            ),
          ],
        ),
        EmptyContent(
          children: [
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () {},
              child: const Text('Upload Files'),
            ),
          ],
        ),
      ],
    ),
  );
}
