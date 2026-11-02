import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldDefaultExample extends StatefulWidget {
  const FieldDefaultExample({super.key});

  @override
  State<FieldDefaultExample> createState() => _FieldDefaultExampleState();
}

class _FieldDefaultExampleState extends State<FieldDefaultExample> {
  static const _maxWidth = 448.0;

  final _name = FocusNode();
  final _about = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldSet(
      children: [
        const FieldLegend(Text('Your notebook')),
        const FieldDescription(
          Text('Everything is saved as you write, in pencil.'),
        ),
        FieldGroup(
          children: [
            Field(
              children: [
                FieldLabel(focusNode: _name, child: const Text('Name')),
                Input(focusNode: _name, placeholder: 'Field notes'),
                const FieldDescription(
                  Text('Shows on the spine. You can change it later.'),
                ),
              ],
            ),
            Field(
              children: [
                FieldLabel(focusNode: _about, child: const Text('About')),
                Textarea(focusNode: _about, placeholder: 'What is it for?'),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
