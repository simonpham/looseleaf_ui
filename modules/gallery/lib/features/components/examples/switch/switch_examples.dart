import 'package:gallery/features/components/examples/switch/switch.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/switch/`.
const switchExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Flip it: the marker fills the track and the paper coin slides across. The label toggles it too.',
    layout: ExampleLayout.stack,
    source: 'switch/switch_default_example.dart',
    builder: SwitchDefaultExample.new,
  ),
  GalleryExample(
    title: 'Sizes and states',
    description: 'Default and sm, off and on, invalid (red pencil outline that stays red when it is on) and disabled (dashed pencil, graphite fill). The thumb\'s side and the fill carry the state, so it never rests on color alone.',
    layout: ExampleLayout.stack,
    source: 'switch/switch_states_example.dart',
    builder: SwitchStatesExample.new,
  ),
  GalleryExample(
    title: 'Settings list',
    description: 'The usual settings page: a title and a line of help on the left, the switch at the end. Hovering anywhere on a row lights its switch.',
    layout: ExampleLayout.stack,
    source: 'switch/switch_settings_list_example.dart',
    builder: SwitchSettingsListExample.new,
  ),
  GalleryExample(
    title: 'In a form',
    description: 'A switch in a form: Save reads each one, "weekly" for the digest when it is on, "off" when it is not. Controlled here, so the summary follows it.',
    layout: ExampleLayout.stack,
    source: 'switch/switch_in_a_form_example.dart',
    builder: SwitchInAFormExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official switch-demo: a switch and its label. Flip it and the marker fills the track while the paper coin slides across; the label toggles it too.',
    source: 'switch/switch_demo_example.dart',
    builder: SwitchDemoExample.new,
  ),
];
