import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerEmptyExample extends StatelessWidget {
  const SpinnerEmptyExample({super.key});

  @override
  Widget build(BuildContext context) => Empty(
    children: [
      const EmptyHeader(
        children: [
          EmptyMedia(variant: EmptyMediaVariant.icon, child: Spinner()),
          EmptyTitle(child: Text('Processing your request')),
          EmptyDescription(
            child: Text(
              'Please wait while we process your request. Do not refresh the page.',
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    ],
  );
}
