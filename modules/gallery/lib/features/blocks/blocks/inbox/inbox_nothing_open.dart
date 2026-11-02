import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The reading side before a letter is picked: a paper plane and a nudge.
///
/// Mirrors `NothingOpen` in upstream
/// `src/blocks/inbox/components/inbox-reading-pane.tsx`.
class InboxNothingOpen extends StatelessWidget {
  const InboxNothingOpen({super.key});

  @override
  Widget build(BuildContext context) => const Paper(
    tilt: false,
    seed: 'inbox-empty',
    child: Center(
      child: Empty(
        children: [
          EmptyHeader(
            children: [
              EmptyMedia(doodle: 'paper-plane', size: 88),
              EmptyTitle(child: Text('Pick a letter to read')),
              EmptyDescription(
                child: Text('It opens here, on a sheet of its own.'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
