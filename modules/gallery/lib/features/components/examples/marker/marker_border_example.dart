import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerBorderExample extends StatelessWidget {
  const MarkerBorderExample({super.key});

  static const _rows = [
    ('git-branch', 'Switched to release-candidate'),
    ('search', 'Reviewed 8 related files'),
    ('file-text', 'Opened implementation notes'),
  ];

  @override
  Widget build(BuildContext context) => MarkerColumn(
    gap: Spacing.d12,
    children: [
      for (final (icon, label) in _rows)
        Marker(
          variant: MarkerVariant.border,
          children: [
            MarkerIcon(child: InkIcon(icon)),
            MarkerContent(child: Text(label)),
          ],
        ),
    ],
  );
}
