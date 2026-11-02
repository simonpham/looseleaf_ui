import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldResponsiveExample extends StatelessWidget {
  const FieldResponsiveExample({super.key});

  static const _maxWidth = 896.0;
  static const _controlWidth = 300.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldSet(
      children: [
        const FieldLegend(Text('Profile')),
        const FieldDescription(Text('Fill in your profile information.')),
        const FieldSeparator(),
        FieldGroup(
          children: [
            const Field(
              orientation: FieldOrientation.responsive,
              children: [
                FieldContent(
                  children: [
                    FieldLabel(child: Text('Name')),
                    FieldDescription(
                      Text('Provide your full name for identification'),
                    ),
                  ],
                ),
                SizedBox(
                  width: _controlWidth,
                  child: Input(placeholder: 'Evil Rabbit'),
                ),
              ],
            ),
            const FieldSeparator(),
            const Field(
              orientation: FieldOrientation.responsive,
              children: [
                FieldContent(
                  children: [
                    FieldLabel(child: Text('Message')),
                    FieldDescription(
                      Text(
                        'You can write your message here. Keep it short, preferably under 100 characters.',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: _controlWidth,
                  child: Textarea(
                    placeholder: 'Hello, world!',
                    resizable: false,
                  ),
                ),
              ],
            ),
            const FieldSeparator(),
            Field(
              orientation: FieldOrientation.responsive,
              children: [
                Button(onPressed: () {}, child: const Text('Submit')),
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
