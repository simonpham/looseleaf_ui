import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldGroupExample extends StatefulWidget {
  const FieldGroupExample({super.key});

  @override
  State<FieldGroupExample> createState() => _FieldGroupExampleState();
}

class _FieldGroupExampleState extends State<FieldGroupExample> {
  static const _maxWidth = 448.0;
  static const _normal = TextStyle(fontWeight: FontWeight.w400);

  var _pushTasks = false;
  var _emailTasks = false;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldGroup(
      children: [
        const FieldSet(
          children: [
            FieldLegend(Text('Responses'), variant: FieldLegendVariant.label),
            FieldDescription(
              Text(
                'Get notified when ChatGPT responds to requests that take time, like research or image generation.',
              ),
            ),
            FieldGroup(
              children: [
                Field(
                  orientation: FieldOrientation.horizontal,
                  disabled: true,
                  children: [
                    Checkbox(value: true, disabled: true),
                    FieldLabel(
                      child: Text('Push notifications', style: _normal),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const FieldSeparator(),
        FieldSet(
          children: [
            const FieldLegend(Text('Tasks'), variant: FieldLegendVariant.label),
            const FieldDescription(
              Text.rich(
                TextSpan(
                  text: "Get notified when tasks you've created have updates. ",
                  children: [
                    TextSpan(
                      text: 'Manage tasks',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ),
            FieldGroup(
              children: [
                Field(
                  orientation: FieldOrientation.horizontal,
                  children: [
                    Checkbox(
                      value: _pushTasks,
                      onChanged: (value) => setState(() => _pushTasks = value),
                    ),
                    FieldLabel(
                      onPressed: () => setState(() => _pushTasks = !_pushTasks),
                      child: const Text('Push notifications', style: _normal),
                    ),
                  ],
                ),
                Field(
                  orientation: FieldOrientation.horizontal,
                  children: [
                    Checkbox(
                      value: _emailTasks,
                      onChanged: (value) => setState(() => _emailTasks = value),
                    ),
                    FieldLabel(
                      onPressed: () =>
                          setState(() => _emailTasks = !_emailTasks),
                      child: const Text('Email notifications', style: _normal),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
