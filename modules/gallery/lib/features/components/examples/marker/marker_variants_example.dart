import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerVariantsExample extends StatelessWidget {
  const MarkerVariantsExample({super.key});

  @override
  Widget build(BuildContext context) => const MarkerColumn(
    children: [
      Marker(
        children: [
          MarkerContent(child: Text('A default marker for inline notes.')),
        ],
      ),
      Marker(
        variant: MarkerVariant.separator,
        children: [MarkerContent(child: Text('A separator marker'))],
      ),
      Marker(
        variant: MarkerVariant.border,
        children: [
          MarkerContent(child: Text('A border marker for row boundaries.')),
        ],
      ),
    ],
  );
}
