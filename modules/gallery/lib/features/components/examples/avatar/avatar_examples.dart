import 'package:gallery/features/components/examples/avatar/avatar.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/avatar/`.
const avatarExamples = <GalleryExample>[
  GalleryExample(
    title: 'Photo and initials',
    description:
        'A picture circled by hand, and what shows while there is none: initials on a disc of marker whose color is chosen from the name. The four sizes are `sm`, `regular`, `lg` and `xl`; `AvatarBadge` puts a status dot on the corner.',
    source: 'avatar/avatar_photo_and_initials_example.dart',
    builder: AvatarPhotoAndInitialsExample.new,
  ),
  GalleryExample(
    title: 'Color from the name',
    description:
        'Give `AvatarFallback` a `name` and it makes the initials, picks one of eight stationery colors from the name (the same person is the same color everywhere) and lets a screen reader hear the full name instead of two letters. `ring` picks the pen of the loop, and `null` draws no loop for long lists.',
    source: 'avatar/avatar_colours_example.dart',
    builder: AvatarColoursExample.new,
  ),
  GalleryExample(
    title: 'Groups',
    description:
        '`AvatarGroup` overlaps faces and a paper-colored ring cuts each one out of the last (`cut` changes the color on a different surface). `AvatarGroupCount` is the sketched disc for everyone who did not fit; it takes text or an icon.',
    height: 240,
    source: 'avatar/avatar_group_example.dart',
    builder: AvatarGroupExample.new,
  ),
  GalleryExample(
    title: 'Team card',
    description:
        'A people list in a card: face, name, role, and a presence dot. Each face is a separate small drawing (the list is short); a list of hundreds would use `ring: null`.',
    height: 460,
    source: 'avatar/avatar_team_example.dart',
    builder: AvatarTeamExample.new,
  ),
];
