import 'package:gallery/features/components/examples/boil/boil.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/boil/`.
const boilExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Four doodles, six redraws a second. The shapes hold still; the lines shiver. Stops when the tab is hidden, off screen, and with reduced motion.',
    height: 200,
    source: 'boil/boil_default_example.dart',
    builder: BoilDefaultExample.new,
  ),
  GalleryExample(
    title: 'Calm, normal, restless',
    description: 'fps and strength tune the shiver. Drawn controls inside a Boil feel it too (through the ink knobs), so a call to action can be alive without any doodle.',
    layout: ExampleLayout.stack,
    height: 240,
    source: 'boil/boil_controls_example.dart',
    builder: BoilControlsExample.new,
  ),
  GalleryExample(
    title: 'A live corner',
    description: 'A real use: the mascot in a card\'s corner and the underline of its heading boil, the text does not. Your own drawings join in with BoilScope.frameOf or BoilScope.seedOf.',
    stage: ExampleStage.desk,
    height: 280,
    source: 'boil/boil_mascot_corner_example.dart',
    builder: BoilMascotCornerExample.new,
  ),
];
