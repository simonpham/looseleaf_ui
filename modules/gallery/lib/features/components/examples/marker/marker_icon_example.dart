import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerIconExample extends StatelessWidget {
  const MarkerIconExample({super.key});

  @override
  Widget build(BuildContext context) => const MarkerColumn(
    gap: Spacing.d48,
    children: [
      Marker(
        children: [
          MarkerIcon(child: InkIcon('git-branch')),
          MarkerContent(child: Text('Switched to a new branch')),
        ],
      ),
      Marker(
        variant: MarkerVariant.separator,
        children: [
          MarkerIcon(child: InkIcon('search')),
          MarkerContent(child: Text('Explored 4 files')),
        ],
      ),
      Marker(
        children: [
          MarkerIcon(child: InkIcon('book-open')),
          MarkerContent(child: Text('Syncing completed')),
        ],
      ),
    ],
  );
}
