import 'package:gallery/features/components/examples/textarea/textarea.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/textarea/`.
const textareaExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Grows with what you write. The resize handle in the corner is drawn by hand.',
    layout: ExampleLayout.stack,
    source: 'textarea/textarea_default_example.dart',
    builder: TextareaDefaultExample.new,
  ),
  GalleryExample(
    title: 'Ruled paper',
    description:
        'ruled draws pencil lines on the baselines of the text. The rules are re-pulled as the box grows, so they always end where the paper does.',
    layout: ExampleLayout.stack,
    source: 'textarea/textarea_ruled_example.dart',
    builder: TextareaRuledExample.new,
  ),
  GalleryExample(
    title: 'Counter and states',
    description:
        'showCount with maxLength; the second field turns red when it is too short. Disabled and read-only fields are drawn as such.',
    layout: ExampleLayout.stack,
    source: 'textarea/textarea_counter_and_states_example.dart',
    builder: TextareaCounterAndStatesExample.new,
  ),
  GalleryExample(
    title: 'A feedback form',
    description:
        'Label, Input and a ruled Textarea in a real form: the note is required, and the button says what happened.',
    layout: ExampleLayout.stack,
    source: 'textarea/textarea_feedback_form_example.dart',
    builder: TextareaFeedbackFormExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description:
        'Official `textarea-demo`: a bare textarea with a placeholder. It sits in a hand-drawn box that grows with its text and redraws the resize grip in its corner. Only addition: a semanticLabel, since there is no visible label.',
    source: 'textarea/textarea_demo_example.dart',
    builder: TextareaDemoExample.new,
  ),
  GalleryExample(
    title: 'Disabled',
    description:
        'Official `textarea-disabled`: the same field with `disabled`. The box is redrawn dashed in pencil gray, so the state does not rest on color alone.',
    source: 'textarea/textarea_disabled_example.dart',
    builder: TextareaDisabledExample.new,
  ),
  GalleryExample(
    title: 'With button',
    description:
        "Official `textarea-with-button`: the field stacked over a full-width Send button. The gap is 12 px (the original's 8 plus a pencil's width): a marker band bleeds a few pixels past its box, and a wide one would touch the field.",
    source: 'textarea/textarea_with_button_example.dart',
    builder: TextareaWithButtonExample.new,
  ),
  GalleryExample(
    title: 'With label',
    description:
        'Official `textarea-with-label`: a Label tied to the field by its focusNode, so a click on the words puts the cursor in the box.',
    source: 'textarea/textarea_with_label_example.dart',
    builder: TextareaWithLabelExample.new,
  ),
  GalleryExample(
    title: 'With text',
    description:
        'Official `textarea-with-text`: a label, the field and a line of help text below. The help is read with the field as its hint (the original leaves it unlinked).',
    source: 'textarea/textarea_with_text_example.dart',
    builder: TextareaWithTextExample.new,
  ),
];
