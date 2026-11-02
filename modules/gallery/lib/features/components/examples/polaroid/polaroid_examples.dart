import 'package:gallery/features/components/examples/polaroid/polaroid.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/polaroid/`.
const polaroidExamples = <GalleryExample>[
  GalleryExample(
    title: 'A polaroid',
    description: 'The frame, the recessed window, the caption in the foot. Here the window holds a drawn scene; a real photograph goes in the same place.',
    stage: ExampleStage.desk,
    source: 'polaroid/polaroid_default_example.dart',
    builder: PolaroidDefaultExample.new,
  ),
  GalleryExample(
    title: 'Four scenes, four ways to hold it up',
    description: 'Hills, sea, a house and a night sky, drawn in marker and felt tip. Taped, pinned, clipped and washi-taped; the sea has a date stamp.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'polaroid/polaroid_scenes_example.dart',
    builder: PolaroidScenesExample.new,
  ),
  GalleryExample(
    title: 'Developing',
    description: '`develop` starts the picture milky and clears it. Change the key and it happens again; with reduced motion the picture is just there.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'polaroid/polaroid_developing_example.dart',
    builder: PolaroidDevelopingExample.new,
  ),
  GalleryExample(
    title: 'A photo wall',
    description: 'A real composition: photographs at different tilts, overlapping a little, with a sticker stuck on. The window takes anything: here every picture is a drawn scene, in an app it would be an `Image`.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 460,
    source: 'polaroid/polaroid_photo_wall_example.dart',
    builder: PolaroidPhotoWallExample.new,
  ),
];
