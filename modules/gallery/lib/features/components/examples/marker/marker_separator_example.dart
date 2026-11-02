import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerSeparatorExample extends StatelessWidget {
  const MarkerSeparatorExample({super.key});

  @override
  Widget build(BuildContext context) => MarkerColumn(
    children: [
      for (final label in const [
        'Today',
        'Worked for 42s',
        'Conversation compacted',
      ])
        Marker(
          variant: MarkerVariant.separator,
          children: [MarkerContent(child: Text(label))],
        ),
    ],
  );
}
