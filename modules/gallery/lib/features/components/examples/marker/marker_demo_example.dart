import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerDemoExample extends StatelessWidget {
  const MarkerDemoExample({super.key});

  @override
  Widget build(BuildContext context) => MarkerColumn(
    children: [
      const Marker(
        children: [
          MarkerIcon(child: InkIcon('git-branch')),
          MarkerContent(child: Text('Switched to a new branch')),
        ],
      ),
      Semantics(
        liveRegion: true,
        child: const Marker(
          children: [
            MarkerIcon(child: Spinner()),
            MarkerContent(
              child: AttachmentPulse(active: true, child: Text('Thinking...')),
            ),
          ],
        ),
      ),
      const Marker(
        variant: MarkerVariant.separator,
        children: [MarkerContent(child: Text('Conversation compacted'))],
      ),
      const Marker(
        children: [
          MarkerIcon(child: InkIcon('search')),
          MarkerContent(child: Text('Explored 4 files')),
        ],
      ),
    ],
  );
}
