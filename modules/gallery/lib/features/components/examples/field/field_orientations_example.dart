import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldOrientationsExample extends StatefulWidget {
  const FieldOrientationsExample({super.key});

  @override
  State<FieldOrientationsExample> createState() =>
      _FieldOrientationsExampleState();
}

class _FieldOrientationsExampleState extends State<FieldOrientationsExample> {
  static const _maxWidth = Spacing.d512;
  static const _inputMaxWidth = Spacing.d224;

  var _sync = true;
  var _terms = true;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldGroup(
      children: [
        Field(
          orientation: FieldOrientation.horizontal,
          children: [
            FieldContent(
              children: [
                FieldLabel(
                  onPressed: () => setState(() => _sync = !_sync),
                  child: const Text('Sync to the cloud'),
                ),
                const FieldDescription(
                  Text('Keeps every page on all your devices.'),
                ),
              ],
            ),
            Switch(
              value: _sync,
              onChanged: (value) => setState(() => _sync = value),
            ),
          ],
        ),
        const FieldSeparator(),
        Field(
          orientation: FieldOrientation.horizontal,
          children: [
            Checkbox(
              value: _terms,
              onChanged: (value) => setState(() => _terms = value),
            ),
            FieldContent(
              children: [
                FieldLabel(
                  onPressed: () => setState(() => _terms = !_terms),
                  child: const Text('Accept the terms'),
                ),
                const FieldDescription(
                  Text('You agree to the small print and the big print.'),
                ),
              ],
            ),
          ],
        ),
        const FieldSeparator(child: Text('responsive')),
        const Field(
          orientation: FieldOrientation.responsive,
          children: [
            FieldContent(
              children: [
                FieldTitle(Text('Display name')),
                FieldDescription(
                  Text('Stacks on narrow boxes, sits in a row on wide ones.'),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: _inputMaxWidth,
                child: Input(placeholder: 'Ada', semanticLabel: 'Display name'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
