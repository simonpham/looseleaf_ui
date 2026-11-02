import 'package:gallery/features/components/examples/sonner/sonner.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sonner/`.
const sonnerExamples = <GalleryExample>[
  GalleryExample(
    title: 'Types',
    description: 'Six kinds of paper: a plain slip, a green guest check for success, a pink sticky for errors, yellow for warnings, blue for news, and a slip with a spinning loader. Each has its own drawn icon and a slightly different tilt.',
    source: 'sonner/sonner_types_example.dart',
    builder: SonnerTypesExample.new,
  ),
  GalleryExample(
    title: 'Promise',
    description: 'toast.promise follows a request: one slip that starts as a loader, then turns into a success (or an error) paper when the future completes. The messages are functions of the result.',
    source: 'sonner/sonner_promise_example.dart',
    builder: SonnerPromiseExample.new,
  ),
  GalleryExample(
    title: 'Action and undo',
    description: 'The real pattern: do the thing at once, then offer to take it back. The action is a highlighter-marked button; the page updates when you press it.',
    source: 'sonner/sonner_undo_example.dart',
    builder: SonnerUndoExample.new,
  ),
  GalleryExample(
    title: 'Positions, tape and pin',
    description: 'Six places to stack toasts (slips not on the right are dropped from above instead of tossed from the corner), and two ways to hold them down: masking tape or a push-pin.',
    source: 'sonner/sonner_positions_and_fasteners_example.dart',
    builder: SonnerPositionsAndFastenersExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `sonner-demo`: one button, one toast with a description and an Undo action. The slip is tossed onto the desk; Undo is a highlighted word, not a filled button. Real apps wrap the app in one `Toaster`; here the example mounts its own so it works on its own.',
    source: 'sonner/sonner_demo_example.dart',
    builder: SonnerDemoExample.new,
  ),
  GalleryExample(
    title: 'Types',
    description: 'Official `sonner-types`: default, success, info, warning, error and a promise that goes from loading to success after two seconds. Each type is a different stock of paper (guest check, blue, yellow and pink stickies), so meaning never rests on color alone.',
    source: 'sonner/sonner_official_types_example.dart',
    builder: SonnerOfficialTypesExample.new,
  ),
];
