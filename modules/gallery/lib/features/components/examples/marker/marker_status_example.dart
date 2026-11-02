import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerStatusExample extends StatelessWidget {
  const MarkerStatusExample({super.key});

  @override
  Widget build(BuildContext context) => MarkerColumn(
    children: [
      Semantics(
        liveRegion: true,
        child: const Marker(
          children: [
            MarkerIcon(child: Spinner()),
            MarkerContent(child: Text('Compacting conversation')),
          ],
        ),
      ),
      Semantics(
        liveRegion: true,
        child: const Marker(
          variant: MarkerVariant.separator,
          children: [
            MarkerIcon(child: Spinner()),
            MarkerContent(child: Text('Running tests')),
          ],
        ),
      ),
    ],
  );
}
