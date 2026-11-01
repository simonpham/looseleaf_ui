import 'package:looseleaf_ink/looseleaf_ink.dart';

/// The drawing shown for an unknown icon name: a box with a question mark.
///
/// Mirrors `MISSING` in upstream `src/components/ui/icon.tsx`.
const ArtDef missingIcon = ArtDef(
  grid: ArtGrid.icon,
  kind: ArtKind.icon,
  parts: [
    StrokePart('M4.6 4.8 L19.3 4.5 L19.5 19.2 L4.4 19.5 Z', 0.9),
    StrokePart(
      'M9.4 9.6 Q9.6 7.4 12.1 7.4 Q14.7 7.5 14.6 9.7 Q14.5 11.4 12.3 12.3 L12.1 14',
      1.1,
    ),
    DotPart(12, 16.8, 1.1),
  ],
);
