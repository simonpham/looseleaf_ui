import 'package:gallery/features/components/examples/empty/empty.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/empty/`.
const emptyExamples = <GalleryExample>[
  GalleryExample(
    title: 'Icon tile',
    description:
        'The upstream layout: media, title, description and an action. `EmptyMediaVariant.icon` puts the icon on a little slip of paper with a hatched shadow; the title is in the script font.',
    height: 360,
    source: 'empty/empty_icon_tile_example.dart',
    builder: EmptyIconTileExample.new,
  ),
  GalleryExample(
    title: 'Stubby',
    description:
        '`pose` asks for Stubby, the pencil stub who does the drawing: `search` for no results, `sleep` for a quiet day, `unplug` for offline, and the rest of the poses as they are drawn (see the props). Media is decorative, so the title carries the meaning.',
    layout: ExampleLayout.stack,
    source: 'empty/empty_stubby_example.dart',
    builder: EmptyStubbyExample.new,
  ),
  GalleryExample(
    title: 'Placeholder frame',
    description:
        '`framed` asks for the sketched dashed frame, with a tick at each corner where the hand marked out the rectangle first. Here it stands for a drop target with a button to choose files; a doodle is the media, and `doodle` takes any name from the Doodle component.',
    stage: ExampleStage.desk,
    height: 400,
    source: 'empty/empty_dropzone_example.dart',
    builder: EmptyDropzoneExample.new,
  ),
  GalleryExample(
    title: 'Search with no results',
    description:
        'A real use: a filterable list that turns into an empty state when nothing matches, with an action that puts the list back. Type something that is not a name.',
    height: 520,
    source: 'empty/empty_no_results_example.dart',
    builder: EmptyNoResultsExample.new,
  ),
  GalleryExample(
    title: 'Four icons',
    description:
        'shadcn\'s `empty-icon`: four bare empty states in a two-column grid, each an icon tile, a title and one line. No action, so the page just says what it is missing.',
    source: 'empty/empty_four_icons_example.dart',
    builder: EmptyFourIconsExample.new,
  ),
  GalleryExample(
    title: 'Avatar',
    description:
        'shadcn\'s `empty-avatar`: the regular media variant leaves the media bare, so any widget can stand there. A face here (initials on marker; the photo of the original is left out so the page needs no network).',
    source: 'empty/empty_avatar_example.dart',
    builder: EmptyAvatarExample.new,
  ),
  GalleryExample(
    title: 'Avatar group',
    description:
        'shadcn\'s `empty-avatar-group`: three overlapping faces in the media slot, in an AvatarGroup that sizes and rings them, and an invite button.',
    source: 'empty/empty_avatar_group_example.dart',
    builder: EmptyAvatarGroupExample.new,
  ),
  GalleryExample(
    title: 'Input group',
    description:
        'shadcn\'s `empty-input-group`: a 404 with no media at all, a search field with a magnifier and a `/` keycap, and a support link under it.',
    source: 'empty/empty_input_group_example.dart',
    builder: EmptyInputGroupExample.new,
  ),
  GalleryExample(
    title: 'Outline',
    description:
        'shadcn\'s `empty-outline`: a dashed border on the root. Here the border is the sketched placeholder frame (`framed`): a dashed line drawn round the space, as if the thing were to be pasted in.',
    source: 'empty/empty_outline_example.dart',
    builder: EmptyOutlineExample.new,
  ),
  GalleryExample(
    title: 'Background',
    description:
        'shadcn\'s `empty-background`: a soft wash that fades from the muted tone into the paper. Any background goes behind the root; it is a plain decoration, nothing is redrawn.',
    source: 'empty/empty_background_example.dart',
    builder: EmptyBackgroundExample.new,
  ),
];
