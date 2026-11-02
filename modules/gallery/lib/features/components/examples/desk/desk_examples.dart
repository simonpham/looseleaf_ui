import 'package:gallery/features/components/examples/desk/desk.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/desk/`.
const deskExamples = <GalleryExample>[
  GalleryExample(
    title: 'The bare desk',
    description:
        'Sage bookcloth under a lamp. Paper lies on it with a short umber shadow and the light from the upper left.',
    layout: ExampleLayout.full,
    source: 'desk/desk_default_example.dart',
    builder: DeskDefaultExample.new,
  ),
  GalleryExample(
    title: 'Things on the blotter',
    description:
        'objects lays a coffee ring, a pencil, paper clips, a ruler and push-pins behind your content. Pick some or take them all.',
    layout: ExampleLayout.full,
    source: 'desk/desk_objects_example.dart',
    builder: DeskObjectsExample.new,
  ),
  GalleryExample(
    title: 'Lamp strength',
    description:
        'The vignette darkens toward the corners. lamp: 0 is a flat blotter, 1 the theme\'s own (a whisper of shade), 2.5 a dim room.',
    layout: ExampleLayout.full,
    source: 'desk/desk_lamp_example.dart',
    builder: DeskLampExample.new,
  ),
  GalleryExample(
    title: 'A morning at the desk',
    description:
        'A whole workspace: a punched page, an index card taped up and two sticky notes, with the pencil and the coffee ring behind them.',
    layout: ExampleLayout.full,
    source: 'desk/desk_morning_desk_example.dart',
    builder: DeskMorningDeskExample.new,
  ),
];
