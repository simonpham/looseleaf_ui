import 'package:gallery/features/components/examples/alert_dialog/alert_dialog.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/alert-dialog/`.
const alertDialogExamples = <GalleryExample>[
  GalleryExample(
    title: 'Delete (danger)',
    description: 'The risky question: hazard tape across the top corners, a red patch behind the icon, and a hatched destructive answer. Focus starts on Cancel.',
    source: 'alert_dialog/alert_dialog_delete_notebook_example.dart',
    builder: AlertDialogDeleteNotebookExample.new,
  ),
  GalleryExample(
    title: 'Small',
    description: 'AlertDialogSize.small: a narrow, centered sheet with the two answers in equal columns. Good for quick confirmations.',
    source: 'alert_dialog/alert_dialog_small_example.dart',
    builder: AlertDialogSmallExample.new,
  ),
  GalleryExample(
    title: 'Media tones',
    description: 'The round patch behind the media says what kind of question this is: highlighter for a plain confirmation, sky for information, red pencil for danger.',
    source: 'alert_dialog/alert_dialog_media_tones_example.dart',
    builder: AlertDialogMediaTonesExample.new,
  ),
  GalleryExample(
    title: 'Async action (controlled)',
    description: 'A confirmation that does real work: the action keeps the dialog open while it runs (closeOnPress: false), disables both answers, then closes it and the page reports the result.',
    source: 'alert_dialog/alert_dialog_async_delete_example.dart',
    builder: AlertDialogAsyncDeleteExample.new,
  ),
  GalleryExample(
    title: 'Are you absolutely sure?',
    description: 'The shadcn demo with no extras: an outline trigger, a title, one paragraph and the two answers. Focus starts on Cancel, Escape closes it, a click on the backdrop does not, and focus returns to the trigger.',
    source: 'alert_dialog/alert_dialog_are_you_sure_example.dart',
    builder: AlertDialogAreYouSureExample.new,
  ),
];
