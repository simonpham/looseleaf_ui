import 'package:gallery/features/components/examples/stepper/stepper.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/stepper/`.
const stepperExamples = <GalleryExample>[
  GalleryExample(
    title: 'Quantity',
    description: 'Press the plus, hold it to run, or type. Arrow keys step, Shift or PageUp / PageDown jump ten, Home and End go to the ends. At 10 the plus has nothing left and rattles the box.',
    height: 200,
    source: 'stepper/stepper_quantity_example.dart',
    builder: StepperQuantityExample.new,
  ),
  GalleryExample(
    title: 'Steps, decimals and units',
    description: 'A step of 0.5 on a price (no float drift, shown with two places), a temperature in whole degrees with the wheel opt-in (click into it and scroll), and a value that snaps to multiples of five.',
    layout: ExampleLayout.stack,
    height: 320,
    source: 'stepper/stepper_steps_and_format_example.dart',
    builder: StepperStepsAndFormatExample.new,
  ),
  GalleryExample(
    title: 'Cart lines with tally marks',
    description: 'The stepper in a cart: each line counts its quantity in tally marks next to the number, the total follows, and a line at zero says so. The tally is decoration; the number is the truth.',
    stage: ExampleStage.desk,
    height: 520,
    source: 'stepper/stepper_cart_lines_example.dart',
    builder: StepperCartLinesExample.new,
  ),
  GalleryExample(
    title: 'In a form',
    description: 'required refuses an empty field (a blank is put back); Reset puts every stepper back to where it started. The third one is invalid, the fourth disabled.',
    stage: ExampleStage.desk,
    height: 560,
    source: 'stepper/stepper_in_a_form_example.dart',
    builder: StepperInAFormExample.new,
  ),
];
