import 'package:gallery/features/components/examples/slider/slider.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/slider/`.
const sliderExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Drag the knob, or focus it and use the arrow keys, Home, End and Page Up / Down. The marker range follows the value; nothing is redrawn while you drag.',
    layout: ExampleLayout.stack,
    source: 'slider/slider_default_example.dart',
    builder: SliderDefaultExample.new,
  ),
  GalleryExample(
    title: 'Range, ticks and tones',
    description: 'Two values make a range slider. ticks hangs pencil marks under the groove (one per step, or a number of intervals); tone swaps the marker for a highlighter or blue felt.',
    layout: ExampleLayout.stack,
    source: 'slider/slider_range_and_ticks_example.dart',
    builder: SliderRangeAndTicksExample.new,
  ),
  GalleryExample(
    title: 'Vertical',
    description: 'A mixing desk: direction: Axis.vertical stands the groove up; the range grows from the bottom. The last fader is disabled.',
    height: 300,
    source: 'slider/slider_vertical_example.dart',
    builder: SliderVerticalExample.new,
  ),
  GalleryExample(
    title: 'Brush settings',
    description: 'Three controlled sliders in a panel, each with its own readout, and a reset that puts every knob back where it started. The values are the only state; the drawings do not change.',
    layout: ExampleLayout.stack,
    source: 'slider/slider_brush_settings_example.dart',
    builder: SliderBrushSettingsExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official slider-demo: a single value from 0 to 100 at 60% width. The marker range is drawn once and clipped to the value; the only addition is a semanticLabel, which the knob needs.',
    source: 'slider/slider_demo_example.dart',
    builder: SliderDemoExample.new,
  ),
];
