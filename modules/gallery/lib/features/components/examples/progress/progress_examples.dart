import 'package:gallery/features/components/examples/progress/progress.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/progress/`.
const progressExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'A pencil-hatched box colored in with a marker as far as the value says. Change the value and the marker glides to it (a clip on a full-length pass; nothing is redrawn).',
    layout: ExampleLayout.stack,
    source: 'progress/progress_default_example.dart',
    builder: ProgressDefaultExample.new,
  ),
  GalleryExample(
    title: 'Sizes, tones and waiting',
    description: 'sm, default and lg; marker, highlighter, grass and sky inks. Without a value the bar is indeterminate: a marker scribble slides across (it holds still, mid-bar, with reduced motion).',
    layout: ExampleLayout.stack,
    source: 'progress/progress_sizes_tones_waiting_example.dart',
    builder: ProgressSizesTonesWaitingExample.new,
  ),
  GalleryExample(
    title: 'Upload queue',
    description: 'A real-world use: three files at different speeds, an indeterminate bar while one is being checked, a green bar and a tick when it is done. Progress is announced as the bar\'s value; the percentage is text.',
    layout: ExampleLayout.stack,
    source: 'progress/progress_uploads_example.dart',
    builder: ProgressUploadsExample.new,
  ),
  GalleryExample(
    title: 'Steps',
    description: '`max` sets the scale, so value and max can be a step and a step count. The label is the only text; semanticValue reads the step out.',
    layout: ExampleLayout.stack,
    source: 'progress/progress_steps_example.dart',
    builder: ProgressStepsExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `progress-demo`: the bar starts at 13 and jumps to 66 half a second later. The marker is drawn once, full length, and revealed to the value, so the change is a transition. Only addition: a semanticLabel, which a progress bar needs.',
    source: 'progress/progress_demo_example.dart',
    builder: ProgressDemoExample.new,
  ),
];
