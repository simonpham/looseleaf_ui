import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerShimmerExample extends StatelessWidget {
  const MarkerShimmerExample({super.key});

  @override
  Widget build(BuildContext context) => MarkerColumn(
    children: [
      Semantics(
        liveRegion: true,
        child: const Marker(
          children: [
            MarkerContent(
              child: AttachmentPulse(active: true, child: Text('Thinking...')),
            ),
          ],
        ),
      ),
      Semantics(
        liveRegion: true,
        child: const Marker(
          variant: MarkerVariant.separator,
          children: [
            MarkerContent(
              child: AttachmentPulse(
                active: true,
                child: Text('Reading 4 files'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
