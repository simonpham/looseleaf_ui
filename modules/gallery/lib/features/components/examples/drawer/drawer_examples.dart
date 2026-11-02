import 'package:gallery/features/components/examples/drawer/drawer.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/drawer/`.
const drawerExamples = <GalleryExample>[
  GalleryExample(
    title: 'Move goal',
    description:
        'The shadcn demo: a slip pulled up from the bottom, torn along its top edge and taped down by its grab tab. Drag the tape, flick it away, or press Escape.',
    source: 'drawer/drawer_move_goal_example.dart',
    builder: DrawerMoveGoalExample.new,
  ),
  GalleryExample(
    title: 'Directions',
    description:
        'Pull a slip in from any edge. Only the bottom slip is torn and taped (that is where the grab tab belongs); the others are plain slips you drag toward their edge.',
    source: 'drawer/drawer_directions_example.dart',
    builder: DrawerDirectionsExample.new,
  ),
  GalleryExample(
    title: 'Responsive dialog',
    description:
        'A dialog on wide screens and a drawer on phones, from one component. The window width is read from MediaQuery, so it swaps when the window crosses 640 px.',
    source: 'drawer/drawer_responsive_dialog_example.dart',
    builder: DrawerResponsiveDialogExample.new,
  ),
];
