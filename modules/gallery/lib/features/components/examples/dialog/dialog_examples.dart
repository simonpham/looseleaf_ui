import 'package:gallery/features/components/examples/dialog/dialog.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/dialog/`.
const dialogExamples = <GalleryExample>[
  GalleryExample(
    title: 'Edit profile',
    description: 'The classic: a form in a dialog. Washi tape across the top corners, the doodled x, and a sheet that drops onto the dimmed page.',
    source: 'dialog/dialog_edit_profile_example.dart',
    builder: DialogEditProfileExample.new,
  ),
  GalleryExample(
    title: 'Paper, edges and props',
    description: 'The sheet is a Paper: any stock, any edge, held down by tape, a clip or a pin. A torn edge is drawn once, when the dialog opens.',
    source: 'dialog/dialog_paper_and_props_example.dart',
    builder: DialogPaperAndPropsExample.new,
  ),
  GalleryExample(
    title: 'Long content',
    description: 'The sheet never scrolls (its shadow and tape would be clipped): put tall content in DialogBody, and the header and footer stay put. Very tall dialogs scroll under the lamp.',
    source: 'dialog/dialog_long_content_example.dart',
    builder: DialogLongContentExample.new,
  ),
  GalleryExample(
    title: 'Invite a teammate (controlled)',
    description: 'A real flow: a controlled dialog around a form. Submitting closes it and the page answers; the field is cleared for next time. Focus returns to the trigger.',
    source: 'dialog/dialog_invite_teammate_example.dart',
    builder: DialogInviteTeammateExample.new,
  ),
  GalleryExample(
    title: 'Share link',
    description: 'shadcn\'s `dialog-close-button`, written the same way: a read-only field, a footer aligned to the start and a Close button inside DialogClose. The corner x is still there; this one is the labeled way out.',
    source: 'dialog/dialog_close_button_example.dart',
    builder: DialogCloseButtonExample.new,
  ),
];
